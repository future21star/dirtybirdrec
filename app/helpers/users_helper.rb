module UsersHelper
  
  def leaderboard_query page = 1, per_page = 9, all = true
    page = page.to_i
    per_page = per_page.to_i

    if all
      @limit = page * per_page
      @offset = 0
    else
      @limit = per_page
      @offset = (page - 1) * per_page
    end

    users_by_points @limit, @offset
  end

  def user_position user
    unless user.has_role?(:admin)
      users_by_points.map{ |u| u['id'] }.index(user.id) + 1
    end
  end

  private

    def users_by_points limit=nil, offset=nil
      points = "(SELECT SUM(value) FROM badge_points WHERE user_id = users.id)"

      fans = "LEFT OUTER JOIN users_roles ON (users_roles.user_id = users.id) LEFT OUTER JOIN roles ON (roles.id = users_roles.role_id)"

      sql = "SELECT users.id, users.created_at, #{points} as total FROM users #{fans} WHERE roles.id IS NULL ORDER BY total DESC NULLS LAST, users.created_at ASC, users.id ASC"

      sql = sql + " LIMIT #{limit}" if limit
      sql = sql + " OFFSET #{offset}" if offset

      ActiveRecord::Base.connection.execute(sql)
    end
end
