require "rails_helper"

describe "POST /api/v1/users" do
  let(:user) { build(:user) }
  let(:params) { { user: { email: email, name: name, password: password, password_confirmation: password_confirmation } } }
  let(:email) { user.email }
  let(:name) { user.name }
  let(:password) { user.password }
  let(:password_confirmation) { password }

  context "with invalid email" do
    let(:email) { "invalid_email" }
    it "returns a error" do
      is_expected.to eq 400
      body = response.body
      expect(body).to have_json_path("errors/email")
      expect(body).to be_json_eql(%("invalid")).at_path("errors/email/0/error")
    end
  end

  context "with used email address" do
    before { user.save }

    it "returns a error" do
      is_expected.to eq 400
      body = response.body
      expect(body).to have_json_path("errors/email")
      expect(body).to be_json_eql(%("taken")).at_path("errors/email/0/error")
    end
  end

  context "with easy password" do
    let(:password) { "easy" }

    it "returns a error" do
      is_expected.to eq 400
      body = response.body
      expect(body).to have_json_path("errors/password")
      expect(body).to be_json_eql(%("too_short")).at_path("errors/password/0/error")
    end
  end

  context "without match passwords" do
    let(:password_confirmation) { "invalid_password" }
    it "returns a error" do
      is_expected.to eq 400
      body = response.body
      expect(body).to have_json_path("errors/password_confirmation")
      expect(body).to be_json_eql(%("confirmation")).at_path("errors/password_confirmation/0/error")
    end
  end

  context "with valid params" do
    it "returns a user" do
      is_expected.to eq 200
      body = response.body
      expect(body).to have_json_path("user/id")
      expect(body).to be_json_eql(%("#{user.email}")).at_path("user/email")
    end

    it { expect { subject }.to change(User, :count).by(1) }
  end
end
