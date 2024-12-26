require 'dry/monads'

class CsvParallelImportService
  include Dry::Monads[:task]

  def call(csv_rows, workers_count)
    start_time = Time.current

    tasks = csv_rows.each_slice(slice_size(csv_rows.count, workers_count)).map do |batch|
      Task[:io] do
        ActiveRecord::Base.connection_pool.with_connection do
          batch.each { |row| process_row(row) }
        end
      end
    end

    tasks.map(&:wait)

    broadcast_completion(csv_rows.count, start_time)
  end

  private

  def process_row(row)
    result = ProductImporterService.new.call(row.to_h)

    broadcast_message(
      product_name: "✅ #{row['Name']}",
      status: result.success? ? 'success' : 'danger',
      error: result.failure
    )
  rescue StandardError => e
    broadcast_message(
      product_name: row['Name'],
      status: 'danger',
      error: e.message
    )
  end

  def broadcast_message(message)
    Turbo::StreamsChannel.broadcast_prepend_to(
      'product_imports',
      target: 'import-messages',
      partial: 'spree/admin/spree_vetfort/imports/message',
      locals: message
    )
  end

  def slice_size(total_rows, workers_count)
    (total_rows.to_f / workers_count).ceil
  end

  def broadcast_completion(total_rows, start_time)
    duration = Time.current - start_time
    message = {
      product_name: '👌',
      status: 'success',
      error: "Processed #{total_rows} rows in #{duration.round(2)} seconds"
    }

    Rails.logger.info("Import completed: #{message}")
    broadcast_message(message)
  rescue StandardError => e
    Rails.logger.error("Error broadcasting completion: #{e.message}")
  end
end
