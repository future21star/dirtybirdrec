module UsersHelper
  
  def leaderboard_query page = 1, per_page = 9, all = true
    page = page.to_i
    per_page = per_page.to_i
    points = "(SELECT SUM(value) FROM badge_points WHERE user_id = users.id)"
    fans = "LEFT OUTER JOIN users_roles ON (users_roles.user_id = users.id) LEFT OUTER JOIN roles ON (roles.id = users_roles.role_id)"

    if all
      @limit = page * per_page
      @offset = 0
    else
      @limit = per_page
      @offset = (page - 1) * per_page
    end

    sql = "SELECT users.id, users.created_at, #{points} as total FROM users #{fans} WHERE roles.name != 'admin' OR roles.id IS NULL ORDER BY total DESC NULLS LAST, users.created_at ASC LIMIT #{@limit} OFFSET #{@offset}"

    ActiveRecord::Base.connection.execute(sql)
  end
end


