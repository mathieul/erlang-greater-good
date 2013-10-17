defmodule Reminder.DateTime do
  def valid?({ date, time }) do
    try do
      :calendar.valid_date(date) && valid_time?(time)
    rescue
      FunctionClauseError -> false
    end
  end

  def valid?(_), do: false

  def valid_time?({ hours, minutes, seconds }), do: valid_time?(hours, minutes, seconds)
  def valid_time?(hh, mm, ss) when hh >= 0 and hh < 24
                               and mm >= 0 and mm < 60
                               and ss >= 0 and ss < 60, do: true
  def valid_time?(_, _, _), do: false
end
