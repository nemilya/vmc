
module VMC::Cli
  module ServicesHelper
    def display_system_services(services=nil)
      services ||= client.services_info

      display "\n============== System Services ==============\n\n"

      return display "No system services available" if services.empty?

      services_table = table do |t|
        t.headings = 'Service', 'Version', 'Description'
        services.each do |service_type, value|
          value.each do |vendor, version|
            version.each do |version_str, service|
              t << [ vendor, version_str, service[:description] ]
            end
          end
        end
      end
      display services_table
    end

    def display_provisioned_services(services=nil)
      services ||= client.services
      display "\n=========== Provisioned Services ============\n\n"
      display_provisioned_services_table(services)
    end

    def display_provisioned_services_table(services)
      return unless services && !services.empty?
      services_table = table do |t|
        t.headings = 'Name', 'Service'
        services.each do |service|
          t << [ service[:name], service[:vendor] ]
        end
      end
      display services_table
    end

    def create_service_banner(service, name, display_name=false)
      sn = " [#{name}]" if display_name
      display "Creating Service#{sn}: ", false
      client.create_service(service, name)
      display 'OK'.green
    end

    def bind_service_banner(service, appname, check_restart=true)
      display "Binding Service: ", false
      client.bind_service(service, appname)
      display 'OK'.green
      check_app_for_restart(appname) if check_restart
    end

    def unbind_service_banner(service, appname, check_restart=true)
      display "Unbinding Service: ", false
      client.unbind_service(service, appname)
      display 'OK'.green
      check_app_for_restart(appname) if check_restart
    end

    def random_service_name(service)
      r = "%04x" % [rand(0x0100000)]
      "#{service.to_s}-#{r}"
    end

    def check_app_for_restart(appname)
      app = client.app_info(appname)
      cmd = VMC::Cli::Command::Apps.new(@options)
      cmd.restart(appname) if app[:state] == 'STARTED'
    end

  end
end
