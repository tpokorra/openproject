require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe GlobalRole do
  before {GlobalRole.create :name => "globalrole", :permissions => ["permissions"]} # for validate_uniqueness_of

  it {should have_many :principals}
  it {should have_many :principal_roles}
  it {should validate_presence_of :name}
  it {should validate_uniqueness_of :name}
  it {should ensure_length_of(:name).is_at_most(30)}

  describe "attributes" do
    before {@role = GlobalRole.new}

    subject {@role}

    it {should respond_to :name}
    it {should respond_to :permissions}
    it {should respond_to :position}
  end

  describe "methods" do
    describe "WITH no attributes set" do
      before {@role = GlobalRole.new}
      describe :permissions do
        subject {@role.permissions}

        it {should be_an_instance_of(Array)}
        it {should have(0).items}
      end

      describe :permissions= do
        describe "WITH parameter" do
          before {@role.should_receive(:write_attribute).with(:permissions, [:perm1, :perm2])}

          it "should write permissions" do
            @role.permissions = [:perm1, :perm2]
          end

          it "should write permissions only once" do
            @role.permissions = [:perm1, :perm2, :perm2]
          end

          it "should write permissions as symbols" do
            @role.permissions = ["perm1", "perm2"]
          end

          it "should remove empty perms" do
            @role.permissions = [:perm1, :perm2, "", nil]
          end
        end

        describe "WITHOUT parameter" do
          before {@role.should_receive(:write_attribute).with(:permissions, nil)}

          it "should write permissions" do
            @role.permissions = nil
          end
        end
      end

      describe :has_permission? do
        it {@role.has_permission?(:perm).should be_false}
      end

      describe :allowed_to? do
        describe "WITH requested permission" do
          it {@role.allowed_to?(:perm1).should be_false}
        end
      end
    end

    describe "WITH set permissions" do
      before{ @role = GlobalRole.new :permissions => [:perm1, :perm2, :perm3]}

      describe :has_permission? do
        it {@role.has_permission?(:perm1).should be_true}
        it {@role.has_permission?("perm1").should be_true}
        it {@role.has_permission?(:perm5).should be_false}
      end

      describe :allowed_to? do
        describe "WITH requested permission" do
          it {@role.allowed_to?(:perm1).should be_true}
          it {@role.allowed_to?("perm1").should be_true}
          it {@role.allowed_to?(:perm5).should be_false}
        end
      end
    end

    describe "WITH available global permissions defined" do
      before (:each) do
        @role = GlobalRole.new
        @permission_options = [:perm1, :perm2, :perm3]
        Redmine::AccessControl.stub!(:global_permissions).and_return(@permission_options)
      end

      describe :setable_permissions do
        it {@role.setable_permissions.should eql [:perm1, :perm2, :perm3]}
      end
    end

    describe "WITH set name" do
      before{ @role = GlobalRole.new :name => "name"}

      describe :to_s do
        it {@role.to_s.should eql("name")}
      end
    end

    describe :destroy do
      before {@role = GlobalRole.create :name => "global"}

      it {@role.destroy}
    end
  end

end