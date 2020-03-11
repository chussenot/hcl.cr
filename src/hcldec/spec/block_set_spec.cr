module HCLDec
  class BlockSetSpec < Spec
    @[HCL::Label]
    property block_name : String? = nil

    @[HCL::Attribute]
    property block_type : String? = nil

    @[HCL::Block]
    property object : ObjectSpec

    def block_type
      @block_type || block_name || ""
    end
  end
end