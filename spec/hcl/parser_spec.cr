require "../spec_helper"

describe HCL::Parser do
  describe "#parse" do
    it "can parse strings" do
      hcl_string = <<-HEREDOC
        variable "ami" {
          description = "the AMI to use"
        }
      HEREDOC

      parser = HCL::Parser.new(hcl_string)
      parser.values.should eq([
        {
          id: "variable",
          args: ["ami"],
          values: {
            "description" => "the AMI to use"
          },
          blocks: [] of HCL::AST::BlockToken::Value
        }
      ])
    end

    it "can parse floats" do
      hcl_string = "provider \"foo\" {" \
                 "foo = 0.1" \
                 "bar = 1" \
                 "}"
      parser = HCL::Parser.new(hcl_string)

      parser.values.should eq([
        {
          id: "provider",
          args: ["foo"],
          values: {
            "foo" => 0.1_f64,
            "bar" => 1_i64
          },
          blocks: [] of HCL::AST::BlockToken::Value
        }
      ])
    end

    it "can parse booleans & nulls" do
      hcl_string = <<-HEREDOC
        resource "aws_instance" "web" {
          source_dest_check = false
          another_boolean = "true"
          something_i_want_default = null
        }
      HEREDOC

      parser = HCL::Parser.new(hcl_string)
      parser.values.should eq([
        {
          id: "resource",
          args: ["aws_instance", "web"],
          values: {
            "source_dest_check" => false,
            "another_boolean"   => true,
            "something_i_want_default" => nil
          },
          blocks: [] of HCL::AST::BlockToken::Value
        }
      ])
    end

    it "can parse map values" do
      hcl_string = <<-HCL
        config "hello" {
          yoo = "yes"
          development = {
            some_setting = true
          }
        }
      HCL
      parser = HCL::Parser.new(hcl_string)

      parser.values.should eq([
        {
          id: "config",
          args: ["hello"],
          values: {
            "yoo" => "yes",
            "development" => {
              "some_setting" => true
            }
          },
          blocks: [] of HCL::AST::BlockToken::Value
        }
      ])
    end

    it "can parse multiple levels of maps and lists" do
      hcl_string = <<-HCL
        test "hello" {
          resource = [{
            foo = [{
              bar = {}
            }]
          }]
        }
      HCL

      parser = HCL::Parser.new(hcl_string)

      parser.values.should eq([
        {
          id: "test",
          args: ["hello"],
          values: {
            "resource" => [{
              "foo" => [
                {
                  "bar" => {} of String => HCL::AST::ValueType
                }
              ]
            }]
          },
          blocks: [] of HCL::AST::BlockToken::Value
        }
      ])
    end

    it "can parse multiple blocks with nesting" do
      hcl_string = <<-HEREDOC
        # An AMI
        variable "ami" {
          description = "the AMI to use"
        }

        /* A multi
          line comment. */
        resource "aws_instance" "web" {
          ami               = "${var.ami}"
          count             = 2
          source_dest_check = false
          another_boolean = "true"
          something_i_want_default = null

          connection {
            user = "root"

            something "else" {
              foo = "bar"
            }
          }
        }
      HEREDOC

      parser = HCL::Parser.new(hcl_string)
      parser.values.should eq([
        {
          id: "variable",
          args: ["ami"],
          values: {
            "description" => "the AMI to use"
          },
          blocks: [] of HCL::AST::BlockToken::Value
        },
        {
          id: "resource",
          args: ["aws_instance", "web"],
          values: {
            "ami"               => "${var.ami}",
            "count"             => 2_i64,
            "source_dest_check" => false,
            "another_boolean"   => true,
            "something_i_want_default" => nil
          },
          blocks: [
            {
              id: "connection",
              args: [] of Hash(String, HCL::AST::ValueType),
              values: {
                "user" => "root"
              },
              blocks: [
                {
                  id: "something",
                  args: ["else"],
                  values: {
                    "foo" => "bar"
                  },
                  blocks: [] of HCL::AST::BlockToken::Value
                }
              ]
            }
          ]
        }
      ])
    end

    it "can parse nested identifiers" do
      hcl_string = <<-HEREDOC
        resource "aws_instance" "web" {
          ami = var.something.ami_id
        }
      HEREDOC

      parser = HCL::Parser.new(hcl_string)
      parser.values.should eq([
        {
          id: "resource",
          args: ["aws_instance", "web"],
          values: {
            "ami" => {
              id: "var.something.ami_id",
              parts: [
                {
                  id: "var",
                  parts: [] of HCL::AST::IdentifierToken::Value
                },
                {
                  id: "something",
                  parts: [] of HCL::AST::IdentifierToken::Value
                },
                {
                  id: "ami_id",
                  parts: [] of HCL::AST::IdentifierToken::Value
                }
              ]
            }
          },
          blocks: [] of HCL::AST::BlockToken::Value
        }
      ])
    end

    it "can parse function calls" do
      hcl_string = <<-HCL
        config "hello" {
          yoo = some_function(item1, [1, 2, 3], "hello")
        }
      HCL
      parser = HCL::Parser.new(hcl_string)

      parser.values.should eq([
        {
          id: "config",
          args: ["hello"],
          values: {
            "yoo" => {
              id: "some_function",
              args: [
                {
                  id: "item1",
                  parts: [] of HCL::AST::IdentifierToken::Value
                },
                [1_i64, 2_i64, 3_i64],
                "hello"
              ]
            }
          },
          blocks: [] of HCL::AST::BlockToken::Value
        }
      ])
    end
  end
end
