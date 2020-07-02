describe ManageIQ::Providers::Foreman::ConfigurationManager do
  describe "#connect" do
    let(:provider) { configuration_manager.provider }
    let(:configuration_manager) do
      FactoryBot.build(:configuration_manager_foreman)
    end

    it "delegates to the provider" do
      expect(provider).to receive(:connect)
      configuration_manager.connect
    end
  end

  describe ".create_from_params" do
    it "delegates endpoints, zone, name to provider" do
      params = {:zone => FactoryBot.create(:zone), :name => "Foreman"}
      endpoints = [{"role" => "default", "url" => "https://foreman", "verify_ssl" => 0}]
      authentications = [{"authtype" => "default", "userid" => "admin", "password" => "smartvm"}]

      config_manager = described_class.create_from_params(params, endpoints, authentications)

      expect(config_manager.provider.name).to eq("Foreman")
      expect(config_manager.provider.endpoints.count).to eq(1)
    end
  end

  describe "#edit_with_params" do
    let(:configuration_manager) do
      FactoryBot.build(:configuration_manager_foreman, :name => "Foreman", :url => "https://localhost")
    end

    it "updates the provider" do
      params = {:zone => FactoryBot.create(:zone), :name => "Foreman 2"}
      endpoints = [{"role" => "default", "url" => "https://foreman", "verify_ssl" => 0}]
      authentications = [{"authtype" => "default", "userid" => "admin", "password" => "smartvm"}]

      provider = configuration_manager.provider
      expect(provider.name).to eq("Foreman")
      expect(provider.url).to  eq("https://localhost")

      configuration_manager.edit_with_params(params, endpoints, authentications)

      provider.reload
      expect(provider.name).to eq("Foreman 2")
      expect(provider.url).to eq("https://foreman")
    end
  end
end
