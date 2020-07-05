require "dotenv"
require "webmock/rspec"
require "./src/white_book"

include WebMock::API
include WhiteBook

describe VAT do
  before(:each) do
    stub_request(:post, /www.googleapis.com/).to_return(
      status: 200,
      body: '{"access_token":"foo","expires_in":0,"token_type":"Bearer"}',
      headers: { 'Content-Type'=>'application/json' }
    )

    stub_request(:get, /sheets.googleapis/).to_return(
      status: 200,
      body: '{ "values": [ [ "000 000-0000", "1003 004 000000 555666 7779999" ], [ "1111111111", "20030040000005556667779998" ], [ "222222222", "0" ], [ "000", "0" ], [ "xxx", "" ] ] }',
      headers: { 'Content-Type'=>'application/json' }
    )

    stub_request(:get, /wl-api.mf.gov.pl/).to_return(
      status: 200,
      body: '{"result":{"subjects":[{"name":"JAN KOWALSKI","nip":"0000000000","statusVat":"Czynny","regon":"999999999","pesel":null,"krs":null,"residenceAddress":"KWIATOWA 1/2, 00-001 WARSZAWA","workingAddress":null,"representatives":[],"authorizedClerks":[],"partners":[],"registrationLegalDate":"2016-01-01","registrationDenialBasis":null,"registrationDenialDate":null,"restorationBasis":null,"restorationDate":null,"removalBasis":null,"removalDate":null,"accountNumbers":["10030040000005556667779999"],"hasVirtualAccounts":true},{"name":"FOOBAR SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ","nip":"1111111111","statusVat":"Czynny","regon":"888888888","pesel":null,"krs":"0000424242","residenceAddress":null,"workingAddress":"WIOSENNA 10, 00-123 WARSZAWA","representatives":[],"authorizedClerks":[],"partners":[],"registrationLegalDate":"2014-01-01","registrationDenialBasis":null,"registrationDenialDate":null,"restorationBasis":null,"restorationDate":null,"removalBasis":null,"removalDate":null,"accountNumbers":["20030040000005556667779998","20030040000005556667779997"],"hasVirtualAccounts":true},{"name":"BAZBAR SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ","nip":"222222222","statusVat":"Czynny","regon":"333333333","pesel":null,"krs":"0000323232","residenceAddress":null,"workingAddress":"ZIMOWA 1, 00-999 WARSZAWA","representatives":[],"authorizedClerks":[],"partners":[],"registrationLegalDate":"2015-01-01","registrationDenialBasis":null,"registrationDenialDate":null,"restorationBasis":null,"restorationDate":null,"removalBasis":null,"removalDate":null,"accountNumbers":["30030040000005556667779998","30030040000005556667779997"],"hasVirtualAccounts":false}],"requestDateTime":"29-02-2020 13:56:42","requestId":"xyz-123"}}',
    )

    stub_request(:put, /amazonaws.com/).to_return(status: 200)

    subject.create_accounts_list
    subject.create_accounts_data
  end

  it "Should be initiated" do
    expect(subject).to be_an(VAT)
  end

  it "Should remove non digit characteres from NIP and Account numbers" do
    subject.accounts.each do |account|
      expect(account[:nip] =~ /[^0-9]/).to be nil
      expect(account[:account] =~ /[^0-9]/).to be nil
    end
  end

  it "Should create accounts list" do
    expect(subject.accounts.length).to be 5
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
    expect(results.key?(:confimation_response)).to be true
  end

  it "Should generate proper results" do
    results = subject.check_accounts[:accounts]

    expect(results.select { |result| result[:found] }.size).to be 3

    expect(results[0][:found]).to be true
    expect(results[0][:valid]).to be true
    expect(results[0][:virtual]).to be true

    expect(results[1][:valid]).to be true
    expect(results[1][:found]).to be true
    expect(results[1][:virtual]).to be true

    expect(results[2][:found]).to be true
    expect(results[2][:valid]).to be false
    expect(results[2][:virtual]).to be false

    expect(results[3][:found]).to be false
    expect(results[3][:valid]).to be nil
    expect(results[3][:virtual]).to be false
  end

  it "Should store file" do
    path = subject.store
    expect(path).not_to be nil
  end
end
