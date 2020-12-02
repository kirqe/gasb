require 'spec_helper'

describe "ReportRepository" do

  let(:repo) { ReportRepository.new(parser: CacheReportParser) }

  describe "create(id)" do
    it "creates an empty Report object and saves to db" do
      repo.create("term:12345")
      expect(Cache.exists?("term:12345")).to be true
    end

    it "returns the created Report object" do
      expect(repo.create("term:12345")).to be_instance_of(Report)
    end            
  end

  describe "update(id, data)" do
    it "updates existing Report with data" do
      report = repo.create("term:12345")
      report = repo.update(report.term, { value: 2 })
      expect(report.value).to eq(2)
    end

    it "returns the updated Report object" do
      report = repo.create("term:12345")
      expect(repo.update("term:12345", { value: 10 })).to be_instance_of(Report)
    end             
  end

  describe "find(id)" do
    it "returns a Report from db if it exists" do
      repo.create("term:12345")
      report = repo.find("term:12345")
      expect(report.term).to eq('term:12345')
      expect(report.value).to eq(0)
    end

    it "returns nil if Report doesnt exist" do
      report = repo.find("term:123456")
      expect(report).to be_nil
    end        
  end

  describe "delete(id)" do
    it "deletes item from cache" do
      repo.create("day:12345")
      repo.create("week:12345")

      repo.delete("day:12345")
      reports = repo.all
      expect(reports.count).to eq(1)
    end     
  end  

  describe "all" do
    it "gets all items from cache" do
      repo.create("term:12345")
      repo.create("term:123456789")
      reports = repo.all
      expect(reports).to be_instance_of(Array)
      expect(reports.count).to eq(2)
    end

    it "gets all items BY id from cache" do
      repo.create("day:12345")
      repo.create("week:12345")
      reports = repo.all(by: '12345')
      reports1 = repo.all(id: '1')
      expect(reports.count).to eq(2)
      expect(reports1.count).to eq(0)
    end
  end    
end