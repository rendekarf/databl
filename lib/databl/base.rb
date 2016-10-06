module Databl
  class Base

    attr_reader :tabular_data

    DefaultPerPage = 50

    def initialize(params = {}, session_opts = {})
      per_page = params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : DefaultPerPage
      @config = if params.present?
        {
            page: params[:iDisplayStart].to_i/per_page + 1,
            per_page: per_page,
            sort_column: params[:iSortCol_0].to_i,
            sort_direction: params[:sSortDir_0] == 'desc' ? 'desc' : 'asc',
            echo: params[:sEcho].to_i,
            query: params[:sSearch]
        }
      else
        {
            page: 1,
            per_page: DefaultPerPage,
            sort_column: 0,
            sort_direction: 'asc',
            echo: 0,
            query: ''
        }
      end
      @config[:session_opts] = session_opts
    end

    def datablize options = {}, &block
      data = databl_rows
      data = Kaminari.paginate_array(data) if data.is_a? Array

      @total_count = data.count
      @tabular_data = data.page(@config[:page]).per(@config[:per_page])

      if block_given?
        @tabular_data = @tabular_data.map{|data_row| block.call(data_row)}
      end

      generate_response.merge(options)
    end

    protected

    def self.column_names mapping
      @@columns = mapping
    end

    def generate_response
      {
          sEcho: @config[:echo],
          iTotalRecords: @config[:per_page],
          aaData: @tabular_data,
          iTotalDisplayRecords: @total_count
      }
    end

    def query
      @config[:query]
    end

    def sort_column
      @config[:sort_column]
    end

    def sort_direction
      @config[:sort_direction]
    end

    def sort_column_name
      @@columns[sort_column] || @@columns[:default]
    end

    def session_opts
      @config[:session_opts]
    end
  end
end