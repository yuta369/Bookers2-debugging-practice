class ChatsController < ApplicationController
  # showアクションにおいて、関連のないユーザーをブロックする
  before_action :block_non_related_users, only: [:show]

  # チャットルームの表示
  def show
    # チャット相手のユーザーを取得
    @user = User.find(params[:id])

    # 現在のユーザーが参加しているチャットルームの一覧を取得
    rooms = current_user.user_rooms.pluck(:room_id)

    # 相手ユーザーとの共有チャットルームが存在するか確認
    user_rooms = UserRoom.find_by(user_id: @user.id, room_id: rooms)

    unless user_rooms.nil?
      # 共有チャットルームが存在する場合、そのチャットルームを表示
      @room = user_rooms.room
    else
      # 共有チャットルームが存在しない場合、新しいチャットルームを作成
      @room = Room.new
      @room.save

      # チャットルームに現在のユーザーと相手ユーザーを追加
      UserRoom.create(user_id: current_user.id, room_id: @room.id)
      UserRoom.create(user_id: @user.id, room_id: @room.id)
    end

    # チャットルームに関連付けられたメッセージを取得
    @chats = @room.chats

    # 新しいメッセージを作成するための空のChatオブジェクトを生成
    @chat = Chat.new(room_id: @room.id)
  end

  # チャットメッセージの送信
  def create
    # フォームから送信されたメッセージを取得し、現在のユーザーに関連付けて保存
    @chat = current_user.chats.new(chat_params)

    # バリデーションに合格しない場合はエラーを表示
    render :validater unless @chat.save
  end

  # チャットメッセージの削除
  def destroy
    # ログイン中のユーザーに関連するチャットメッセージを削除
    @chat = current_user.chats.find(params[:id])
    @chat.destroy
  end

  private

  # フォームから送信されたパラメータを安全に取得
  def chat_params
    params.require(:chat).permit(:message, :room_id)
  end

  # 関連のないユーザーをブロックする
  def block_non_related_users
    # チャット相手のユーザーを取得
    user = User.find(params[:id])

    # ユーザーがお互いにフォローしているか確認し、していない場合はリダイレクト
    unless current_user.following?(user) && user.following?(current_user)
      redirect_to books_path # リダイレクト先は適切なものに変更しましょう
    end
  end
end