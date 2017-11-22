describe :placeholders do
  include_examples :placeholders, ManageIQ::Providers::Foreman::Engine.root.join('locale').to_s
end
