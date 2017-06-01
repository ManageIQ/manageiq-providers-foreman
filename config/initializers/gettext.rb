Vmdb::Gettext::Domains.add_domain(
  'ManageIQ_Providers_Foreman',
  ManageIQ::Providers::Foreman::Engine.root.join('locale').to_s,
  :po
)
