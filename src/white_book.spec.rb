require "dotenv"
require "webmock/rspec"
require "./src/white_book"

include WebMock::API
include WhiteBook

describe VAT do
  before(:each) do
    date = Time.now.strftime("%Y-%m-%d")

    stub_request(:post, /www.googleapis.com/).to_return(
      status: 200,
      body: '{"access_token":"foo","expires_in":0,"token_type":"Bearer"}',
      headers: { 'Content-Type'=>'application/json' }
    )

    stub_request(:get, /sheets.googleapis/).to_return(
      status: 200,
      body: '{ "values": [ [ "", "12-3" ], [ "", "456" ], [ "", "" ], [ "", "000" ] ] }',
      headers: { 'Content-Type'=>'application/json' }
    )

    stub_request(:get, "https://wl-api.mf.gov.pl/api/search/bank-accounts/123?date=#{date}").to_return(
      status: 200,
      body: '{"result":{"entries":[{"subjects":[{"name":"Foo bar","nip":"1002003000","statusVat":"Czynny","accountNumbers":["123"],"hasVirtualAccounts":false}]}],"requestId":"abc-123"}}',
    )

    stub_request(:get, "https://wl-api.mf.gov.pl/api/search/bank-accounts/456?date=#{date}").to_return(
      status: 200,
      body: '{"result":{"entries":[{"subjects":[{"name":"Baz","nip":"9002005000","statusVat":"Czynny","accountNumbers":["900"],"hasVirtualAccounts":true}]}],"requestId":"defg-123"}}',
    )

    stub_request(:get, "https://wl-api.mf.gov.pl/api/search/bank-accounts/000?date=#{date}").to_return(
      status: 200,
      body: '{"result":{"entries":[{"subjects":[]}],"requestId":"foo-987"}}'
    )

    stub_request(:put, /amazonaws.com/).to_return(status: 200)

    subject.create_accounts_list
    subject.create_accounts_data
  end

  it "Should be initiated" do
    expect(subject).to be_an(VAT)
  end

  it "Should remove non digit characteres from account numbers" do
    subject.accounts.each do |account|
      expect(account[:account] =~ /[^0-9]/).to be nil
    end
  end

  it "Should create accounts list" do
    expect(subject.accounts.length).to be 4
  end


  it "Should return today request date when no declared" do
    expect(subject.date).equal? Time.now.strftime("%Y-%m-%d")
  end

  it "Should create accounts data" do
    expect(subject.accounts_data).not_to be nil
  end

  it "Should return results hash" do
    results = subject.check_accounts

    expect(results.key?(:accounts)).to be true
  end

  it "Should generate proper results" do
    results = subject.check_accounts[:accounts]

    expect(results.select { |result| result[:found] }.size).to be 2

    expect(results[0]).to eq ({
      account: "123",
      found: true,
      company: "Foo bar",
      accountFound: true,
      valid: true,
      hasVirtual: false,
      nip: "1002003000",
      requestId: "abc-123",
      checked: true
    })

    expect(results[1]).to eq ({
      account: "456",
      found: true,
      company: "Baz",
      accountFound: false,
      valid: true,
      hasVirtual: true,
      nip: "9002005000",
      requestId: "defg-123",
      checked: true
    })

    expect(results[2]).to eq ({
      account: "",
      found: false,
      company: nil,
      accountFound: false,
      valid: false,
      hasVirtual: false,
      nip: nil,
      requestId: nil,
      checked: false
    })

    expect(results[3]).to eq ({
      account: "000",
      found: false,
      company: nil,
      accountFound: false,
      valid: false,
      hasVirtual: false,
      nip: nil,
      requestId: "foo-987",
      checked: true
    })
  end

  # TODO: Fix stubbing aws-s3-sdk:

  # it "Should store file" do
  #   path = subject.store

  #   expect(path).not_to be nil
  # end
end
