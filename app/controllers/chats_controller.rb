class ChatsController < ApplicationController
  before_action :reject_non_related, only: [:show]
  
  def show
    @user = User.find(params[:id]) #チャット相手は誰か？
    rooms = current_user.user_rooms.pluck(:room_id) #ログイン中のユーザの部屋情報をすべて取得
                                                    #pluck(:カラム名)
    user_rooms = UserRoom.find_by(user_id: @user.id, room_id: rooms) #その中にチャットする相手とのルームがあるか確認
    
    unless user_rooms.nil? #「ユーザルームが無かった」のunless=つまりあった場合
      @room = user_rooms.room #変数@roomにユーザと紐づいているroomを代入
    else 
      @room = Room.new 
      @room = Room.save
      UserRoom.create(user_id: current_user.id, room_id: @room.id) #自分の中間テーブルを作成。新しいチャットルームの作成
      UserRoom.create(user_id: @user.id, room_id: @room.id) #相手の中間テーブルを作成。新しいチャットルームの作成
    end 
    @chats = @room.chats #チャット一覧用の変数
    @chat = Chat.new(room_id: @room.id) #チャット投稿用の変数
  end 
  
  def create
    @chat = current_user.chats.new(chat_params)
    render :validater unless @chat.save
  end 
  
  private
  def chat_params
    params.require(:chat).permit(:message, :room_id)
  end 
  
  #相互フォローの確認
  def reject_non_related
    user = User.find(params[:id])
    unless current_user.following?(user) && user.following?(current_user)
      redirect_to books_path
    end 
  end 
  
end
