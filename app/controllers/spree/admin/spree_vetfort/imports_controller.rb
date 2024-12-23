module Spree::Admin::SpreeVetfort
  class ImportsController < Spree::Admin::BaseController
    def new
    end

    def create
      unless import_params[:file].present?
        flash[:error] = "File missing"
        return redirect_to new_admin_spree_vetfort_import_path
      end

      unless import_params[:file].content_type == "text/csv"
        flash[:error] = "File is not a CSV"
        return redirect_to new_admin_spree_vetfort_import_path
      end

      file = import_params[:file]
      CSV.foreach(file.path, headers: true) do |row|
        ProductImporterService.new.call(row.to_h)
      end

      redirect_to new_admin_spree_vetfort_import_path
    end

    def template
      csv_string = CSV.generate(headers: true) do |csv|
        csv << ["Sku", "Name", "Price", "Taxons", "Options", "Properties"]
      end

      send_data csv_string, filename: "product_import_template.csv"
    end

    private

    def import_params
      params.permit(:file)
    end
  end
end
