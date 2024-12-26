require 'dry/monads'

module Spree::Admin::SpreeVetfort
  class ImportsController < Spree::Admin::BaseController
    include Dry::Monads[:task]

    RESERVED_CONNECTIONS = 5

    def new; end

    def create
      unless import_params[:file]&.respond_to?(:read)
        flash[:error] = 'Invalid or missing file'
        return redirect_to new_admin_spree_vetfort_import_path
      end

      unless import_params[:file].content_type == 'text/csv'
        flash[:error] = 'File is not a CSV'
        return redirect_to new_admin_spree_vetfort_import_path
      end

      csv_rows = parse_csv(import_params[:file])
      if csv_rows.empty?
        flash[:error] = 'File is empty or invalid'
        return redirect_to new_admin_spree_vetfort_import_path
      end

      workers_count = calculate_optimal_workers(csv_rows.count)
      Task[:io] do
        CsvParallelImportService.new.call(csv_rows, workers_count)
      end

      flash[:success] = 'Начинаю импорт, это может занять некоторое время... ⏳'
      redirect_to new_admin_spree_vetfort_import_path
    end

    def template
      csv_string = CSV.generate(headers: true) do |csv|
        csv << %w[Sku Name Price Taxons Options Properties]
      end

      send_data csv_string, filename: 'product_import_template.csv'
    end

    private

    def calculate_optimal_workers(rows_count)
      available_cores = Etc.nprocessors
      [
        rows_count,
        available_cores,
        ActiveRecord::Base.connection_pool.size - RESERVED_CONNECTIONS
      ].min
    end

    def parse_csv(file)
      content = file.read

      content = if content.encoding == Encoding::ASCII_8BIT
                  content.force_encoding('UTF-8')
                else
                  content.encode('UTF-8')
                end

      CSV.parse(content, headers: true, encoding: 'UTF-8', internal_encoding: 'UTF-8', external_encoding: 'UTF-8')
    rescue CSV::MalformedCSVError => e
      Rails.logger.error("CSV Parse Error: #{e.message}")
      []
    end

    def import_params
      params.permit(:file)
    end
  end
end
