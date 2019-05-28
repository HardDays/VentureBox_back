module EnumsHelper

  def self.c_level
    return [:cto, :cfo, :cio, :coo, :cco, :cko, :cso, :cdo, :cmo]
  end

  def self.c_level_readable_json
    return {
      cto: "CTO",
      cfo: "CFO",
      cio: "CIO",
      coo: "COO",
      cco: "CCO",
      cko: "CKO",
      cso: "CSO",
      cdo: "CDO",
      cmo: "CMO",
    }
  end

  def self.stage_of_funding
    return [:idea, :pre_seed, :seed, :serial_a, :serial_b, :serial_c]
  end

  def self.stage_of_funding_readable_json
    return {
      idea: "Idea",
      pre_seed: "Pre-seed",
      seed: "Seed",
      serial_a: "Serial A",
      serial_b: "Serial B",
      serial_c: "Serial C",
    }
  end

  def self.company_item_tag
    return [:blockchain, :coding, :real_sector, :product, :fintech]
  end

  def self.company_item_tag_readable_json
    return {
      blockchain: "blockchain",
      coding: "coding",
      real_sector: "real sector",
      product: "product",
      fintech: "fintech",
    }
  end
end
