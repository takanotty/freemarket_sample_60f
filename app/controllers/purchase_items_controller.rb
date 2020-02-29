class PurchaseItemsController < ApplicationController
  before_action :set_infomation
  def show
    card = CreditCard.find_by(user_id: current_user.id)
    if card.blank?
      #flash[:alert] = '購入にはクレジットカード登録が必要です'
      redirect_to controller: 'credit_cards', action: 'new_credit_card'
    else
      Payjp.api_key = 'sk_test_11bb9decc79ff2b8baa12827'
      customer = Payjp::Customer.retrieve(card.customer_id)
      @customer_card = customer.cards.retrieve(card.card_id)    
    end
  end

  def purchase_complete
    card = CreditCard.find_by(user_id: current_user.id)
    if card.blank?
      redirect_to controller: 'credit_cards', action: 'new_credit_card'
      #flash[:alert] = '購入にはクレジットカード登録が必要です'
    else
      customer = Payjp::Customer.retrieve(card.customer_id)
      @customer_card = customer.cards.retrieve(card.card_id)  
      # 購入した際の情報を元に引っ張ってくる
      # テーブル紐付けてるのでログインユーザーのクレジットカードを引っ張ってくる
      Payjp.api_key = 'sk_test_11bb9decc79ff2b8baa12827'
      # キーをセットする(環境変数においても良い)
      Payjp::Charge.create(
      amount: @item.price, #支払金額
      customer: card.customer_id, #顧客ID
      currency: 'jpy', #日本円
      )
      # 商品の金額をamountへ、cardの顧客idをcustomerへ、currencyをjpyへ入れる
      if @item.update(buyer_id: current_user.id)
        #flash[:notice] = '購入しました。'
      else
        #flash[:alert] = '購入に失敗しました。'
        redirect_to action: 'show'
      end
    end
  end

  private

  def set_infomation
    @item = Item.find(params[:item_id])
    @sellUser = User.find(@item.seller_id)
    @itemCategory = Category.find(@item.category_id)
    @images = Image.where(item_id:params[:item_id])
    @addresses = Address.find_by(user_id: current_user.id)
  end

end