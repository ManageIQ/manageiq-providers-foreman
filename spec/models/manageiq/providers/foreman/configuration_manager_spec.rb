describe ManageIQ::Providers::Foreman::ConfigurationManager do
  let(:provider) { configuration_manager.provider }
  let(:configuration_manager) do
    FactoryBot.build(:configuration_manager_foreman)
  end

  describe "#connect" do
    it "delegates to the provider" do
      expect(provider).to receive(:connect)
      configuration_manager.connect
    end
  end
end
