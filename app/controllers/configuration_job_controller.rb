class ConfigurationJobController < ApplicationController
  before_action :check_privileges
  before_action :get_session_data
  after_action :cleanup_action
  after_action :set_session_data

  include Mixins::GenericListMixin
  include Mixins::GenericButtonMixin
  include Mixins::GenericSessionMixin

  def self.model
    ManageIQ::Providers::AnsibleTower::AutomationManager::Job
  end

  def self.table_name
    @table_name ||= "configuration_job"
  end

  def ems_path(*args)
    ems_configprovider_path(*args)
  end

  def show
    return if perfmenu_click?
    @display = params[:display] || "main" unless pagination_or_gtl_request?

    @lastaction = "show"
    @configuration_job = @record = identify_record(params[:id])
    return if record_no_longer_exists?(@configuration_job)

    @gtl_url = "/show"
    drop_breadcrumb({:name => _("Configuration_Jobs"),
                     :url  => "/configuration_job/show_list?page=#{@current_page}&refresh=y"}, true)
    case @display
    when "main", "summary_only"
      get_tagdata(@configuration_job)
      drop_breadcrumb(:name => _("%{name} (Summary)") % {:name => @configuration_job.name},
                      :url  => "/configuration_job/show/#{@configuration_job.id}")
      @showtype = "main"
      set_summary_pdf_data if @display == 'summary_only'
    end

    replace_gtl_main_div if pagination_request?
  end

  def parameters
    show_association('parameters', _('Parameters'), 'parameter', :parameters, OrchestrationStackParameter)
  end

  def button
    generic_button_setup

    handle_button_pressed(params[:pressed]) do |pressed|
      return if @flash_array.nil? && pressed.ends_with?("tag")
    end

    check_if_button_is_implemented
    @configuration_job = @record # is this necessary?

    button_render_fallback
  end

  def title
    _("Job")
  end

  private

  def textual_group_list
    [%i(properties relationships), %i(tags)]
  end
  helper_method :textual_group_list

  def handled_buttons
    %w(
      configuration_job_delete
      configuration_job_tag
    )
  end

  def handle_configuration_job_delete
    configuration_job_delete
    redirect_to_retire_screen_if_single_delete
  end

  menu_section :conf
end
