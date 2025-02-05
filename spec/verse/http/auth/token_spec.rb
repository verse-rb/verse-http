# frozen_string_literal: true

RSpec.describe Verse::Http::Auth::Token do

  let(:in_one_hour) { Time.now.to_i + 3600 }
  subject {
    Verse::Http::Auth::Token.encode(
      { id: 1, name: "John Doe" },
      :user,
      { users: [1, 2] },
      exp: in_one_hour
    )
  }

  it "encodes a new token" do
    expect(subject).to be_a String
  end

  it "decodes a token" do
    subject.tap do |token_string|
      token = Verse::Http::Auth::Token.decode(token_string)

      expect(
        token
      ).to be_a Verse::Http::Auth::Token

      expect(token.context.metadata).to eq({ id: 1, name: "John Doe", role: :user })
      expect(token.context.custom_scopes).to eq({ users: [1, 2] })
    end
  end
end
