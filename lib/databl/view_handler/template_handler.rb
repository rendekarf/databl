require 'action_view'
module ActionView
  module Template::Handlers
    class DatablBuilder
      def default_format
        (Rails.version.to_f >= 5) ? Mime[:databl] : Mime::Databl
      end

      def self.call(template)
        "
          #{template.source}.to_json
        "
      end

    end
  end
end

ActionView::Template.register_template_handler :databl, ActionView::Template::Handlers::DatablBuilder