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
    it "returns the number of copies um has"
    it "returns HathiTrust link"
    it "returns electronic record links"
  end
end
