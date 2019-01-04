describe ManageIQ::Providers::Foreman::ConfigurationManager do
  let(:provider) { FactoryBot.build(:provider_foreman) }
  let(:configuration_manager) do
    FactoryBot.build(:configuration_manager_foreman, :provider => provider)
  end

  describe "#connect" do
    it "delegates to the provider" do
      expect(provider).to receive(:connect)
      configuration_manager.connect
    end
  end
end
