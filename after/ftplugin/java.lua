local ok, jdtls = pcall(require, 'jdtls')
if not ok then
  return
end

local mason = vim.fn.stdpath 'data' .. '/mason'

local os_config = (vim.fn.has 'mac' == 1) and 'config_mac' or 'config_linux'

local root_markers = { 'pom.xml', '.git', 'mvnw', 'gradlew' }
local root_dir = require('jdtls.setup').find_root(root_markers)
if not root_dir then
  return
end

local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
-- 可修改
local workspace_dir = mason .. '/jdtls-workspace/' .. project_name

-- bundles: java-debug + java-test
local bundles = {}

local debug_jar = vim.fn.glob(mason .. '/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', 1)
if debug_jar ~= '' then
  table.insert(bundles, debug_jar)
end

local test_jars = vim.fn.glob(mason .. '/packages/java-test/extension/server/*.jar', 1, 1)
if type(test_jars) == 'table' then
  vim.list_extend(bundles, test_jars)
end

local launcher_jar = vim.fn.glob(mason .. '/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar', 1)
if launcher_jar == '' then
  vim.notify('jdtls launcher jar not found under mason', vim.log.levels.ERROR)
  return
end

local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens',
    'java.base/java.util=ALL-UNNAMED',
    '--add-opens',
    'java.base/java.lang=ALL-UNNAMED',
    '-jar',
    launcher_jar,
    '-configuration',
    mason .. '/packages/jdtls/' .. os_config,
    '-data',
    workspace_dir,
  },

  root_dir = root_dir,

  init_options = {
    bundles = bundles,
  },
}

jdtls.start_or_attach(config)

-- ===== vimspector: get DAP port then launch =====

local dap_port_cache

local function get_jdtls_client()
  -- nvim-jdtls 有时提供 get_client；没有的话就从 lsp clients 找
  if type(jdtls.get_client) == 'function' then
    local c = jdtls.get_client()
    if c then
      return c
    end
  end
  for _, c in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    if c.name == 'jdtls' then
      return c
    end
  end
end

local function get_dap_port()
  local client = get_jdtls_client()
  if not client then
    vim.notify('jdtls client not ready', vim.log.levels.ERROR)
    return nil
  end

  local resp = client.request_sync('workspace/executeCommand', { command = 'vscode.java.startDebugSession', arguments = {} }, 10000, 0)

  if resp and resp.err then
    vim.notify(('startDebugSession error: %s'):format(resp.err.message or vim.inspect(resp.err)), vim.log.levels.ERROR)
    return nil
  end

  return resp and resp.result or nil
end

local function vimspector_java_launch()
  if not dap_port_cache or dap_port_cache == '' or dap_port_cache == 0 then
    dap_port_cache = get_dap_port()
  end

  if not dap_port_cache or dap_port_cache == '' or dap_port_cache == 0 then
    vim.notify('Could not get DAPPort from jdtls. Next step: inspect executeCommandProvider.commands.', vim.log.levels.ERROR)
    return
  end

  vim.fn['vimspector#LaunchWithSettings'] { DAPPort = dap_port_cache }
end

vim.keymap.set('n', '<leader><F5>', vimspector_java_launch, {
  buffer = true,
  silent = true,
  desc = 'Java Debug (vimspector) - auto DAPPort',
})
