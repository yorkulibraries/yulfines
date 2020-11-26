require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should "create a valid user" do
    user = build :user

    assert_difference("User.count", 1) do
      user.save
    end
  end

  should "validate email address properly" do
    assert ! build(:user, email: "whatever").valid?, "Email is not valid"
    assert ! build(:user, email: "@coco.com").valid?, "Email is not valid"

    assert build(:user, email: "whatever@what.com").valid?, "Email is valid"
    assert build(:user, email: "whatever.you@testging.co.uk").valid?, "Email is valid"

  end

  should "not create a valid user" do
    assert ! build(:user, email: nil).valid?, "Email is required"
    #assert ! build(:user, password: nil).valid?, "Password is required"
    assert ! build(:user, email: "whatever").valid?, "Email is not valid"


    create :user, email: "test@test.com"
    assert build(:user, email: "test@test.com").valid?, "Email doesn't have to be unique"

    create :user, yorku_id: "123"
    assert ! build(:user, yorku_id: "123").valid?, "YorkU ID must be unique"
  end

  should "be able to change email address or password" do
    user = create :user, email: "test@test.com"

    user.email = "new@test.com"
    user.save

    assert_equal "new@test.com", user.email, "Email should have changed #{user.errors.messages}"

  end

  should "display first name and last name and not bitch" do
      user = create(:user, first_name: "WOOT", last_name: "YEST")
      assert_equal user.first_name, "WOOT"
      assert_equal user.last_name, "YEST"

      user2 = build :user, first_name: "YAMAN", last_name: nil
      user2.save(validate: false)
      assert_equal "YAMAN", user2.name
      assert_equal "Y", user2.initials
  end

  should "return only active user fees" do
    user = create :user

    create :alma_fee, fee_status: "ACTIVE"
    active_fee = create :alma_fee, fee_status: "ACTIVE", yorku_id: user.yorku_id
    paid_fee = create :alma_fee, fee_status: Alma::Fee::STATUS_PAID,  yorku_id: user.yorku_id

    assert_equal 1, user.alma_fees.size
    assert_equal user.alma_fees.first.id, active_fee.id

    assert_equal 1, user.paid_alma_fees.size
    assert_equal user.paid_alma_fees.first.id, paid_fee.id
  end
end
