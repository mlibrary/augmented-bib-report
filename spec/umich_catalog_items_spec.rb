describe UmichCatalogItems do
  context "one item" do
    before(:each) do
      @doc = JSON.parse(fixture("solr_doc.json"))
      @barcode = "39015009714562"
    end
    subject do
      described_class.new([@doc]).item_for_barcode(@barcode)
    end
    it "#callnumber returns string" do
      expect(subject.callnumber).to eq("ML760 .P18")
    end
    it "#mms_id returns string" do
      expect(subject.mms_id).to eq("990003116350106381")
    end
    it "#title returns the display title" do
      expect(subject.title).to eq("The hurdy-gurdy / Susann Palmer, part-author Samuel Palmer ; with a foreword by Francis Baines.")
    end
    it "#author returns main_author_display" do
      expect(subject.author).to eq("Palmer, Susann.")
    end
    it "#inventory_number returns a string" do
      @doc["hol"] = @doc["hol"].sub("inventory_number\":null", "inventory_number\":\"inv_num\"")
      expect(subject.inventory_number).to eq("inv_num")
    end
    it "returns the #description" do
      @doc["hol"] = @doc["hol"].sub("description\":null", "description\":\"description\"")
      expect(subject.description).to eq("description")
    end
    it "returns multiple oclc numbers in an arry" do
      @doc["oclc"].push("oclc12345")
      expect(subject.oclc).to eq(["6961296", "oclc12345"])
    end
    it "returns the list of UM libraries that have items" do
      expect(subject.umich_libraries).to eq(["MUSIC"])
    end
    it "returns HathiTrust item array" do
      expect(subject.hathi_items).to eq(["inu.30000042758924"])
    end
    it "returns array of links" do
      @doc = JSON.parse(fixture("solr_elec_doc.json"))
      @barcode = "39015090074744"
      expect(subject.electronic_items).to eq(["https://na04.alma.exlibrisgroup.com/view/uresolver/01UMICH_INST/openurl-UMAA?u.ignore_date_coverage=true&portfolio_pid=531055396990006381&Force_direct=true"])
    end
  end
end
