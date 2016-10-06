require 'action_controller'
unless defined? Mime::DT
  Mime::Type.register 'application/json', :databl
end

ActionController::Renderers.add :databl do |filename, options|
  #
  # You can always specify a template:
  #
  #  def called_action
  #    render xlsx: 'filename', template: 'controller/diff_action'
  #  end
  #
  # And the normal use case works:
  #
  #  def called_action
  #    render 'diff_action'
  #    # or
  #    render 'controller/diff_action'
  #  end
  #
  if options[:template] == action_name
    options[:template] = filename.gsub(/^.*\//,'')
  end

  # force layout false
  options[:layout] = false

  # disposition / filename
  disposition   = options.delete(:disposition) || 'inline'
  if file_name = options.delete(:filename)
    file_name += ".dt" unless file_name =~ /\.databl/
  else
    file_name = "#{filename.gsub(/^.*\//,'')}.databl"
  end

  mime = (Rails.version.to_f >= 5) ? Mime[:databl] : Mime::Databl
  send_data render_to_string(options), :filename => file_name, :type => mime, :disposition => disposition
end

# For respond_to default
begin
  ActionController::Responder
rescue
else
  class ActionController::Responder
    def to_dt
      if @default_response
        @default_response.call(options)
      else
        controller.render({:databl => controller.action_name}.merge(options))
      end
    end
  end
end