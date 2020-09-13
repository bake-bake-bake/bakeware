defmodule BakewareUpdater do
  @doc """
  Check the default update server for an executable update
  """
  @spec check_for_update(exec_name :: binary(), current_version :: binary(), timeout :: non_neg_integer()) ::
          binary() | map()
  defdelegate check_for_update(exec_name, version, timeout), to: BakewareUpdater.RequestManager
end
