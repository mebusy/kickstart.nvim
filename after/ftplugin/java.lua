local ok, jdtls = pcall(require, 'jdtls')
if not ok then
  return
end

local jdtls_setup = require 'jdtls.setup'

local mason = vim.fn.stdpath 'data' .. '/mason'

-- OS config dir for jdtls (mason packages/jdtls/)
local os_config = (vim.fn.has 'mac' == 1) and 'config_mac' or 'config_linux'

-- Find project root (Maven/Gradle/Git)
local root_markers = { 'pom.xml', 'build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts', '.git', 'mvnw', 'gradlew' }
local root_dir = jdtls_setup.find_root(root_markers)
if not root_dir then
  return
end

-- Stable workspace dir based on root_dir path hash (avoid collisions)
local function workspace_name_from_root(dir)
  -- Turn /a/b/c into a safe-ish name + add a hash suffix
  local base = vim.fn.fnamemodify(dir, ':p:h:t')
  local hash = vim.fn.sha256(dir):sub(1, 12)
  return base .. '-' .. hash
end

local workspace_dir = mason .. '/jdtls-workspace/' .. workspace_name_from_root(root_dir)

-- Collect debug/test bundles from mason
local function collect_bundles()
  local bundles = {}

  local debug_jar = vim.fn.glob(mason .. '/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', 1)
  if debug_jar ~= '' then
    table.insert(bundles, debug_jar)
  end

  local test_jars = vim.fn.glob(mason .. '/packages/java-test/extension/server/*.jar', 1, 1)
  if type(test_jars) == 'table' then
    vim.list_extend(bundles, test_jars)
  end

  return bundles
end

local launcher_jar = vim.fn.glob(mason .. '/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar', 1)
if launcher_jar == '' then
  vim.notify('jdtls launcher jar not found: ' .. mason .. '/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar', vim.log.levels.ERROR)
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
    bundles = collect_bundles(),
  },
}

jdtls.start_or_attach(config)

-- ============ vimspector integration (always fetch fresh port) ============

local function get_jdtls_client()
  -- prefer nvim-jdtls helper if available
  if type(jdtls.get_client) == 'function' then
    local c = jdtls.get_client()
    if c then
      return c
    end
  end
  -- fallback: find attached lsp client
  for _, c in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    if c.name == 'jdtls' then
      return c
    end
  end
end

local function get_fresh_dap_port()
  local client = get_jdtls_client()
  if not client then
    vim.notify('jdtls client not ready', vim.log.levels.ERROR)
    return nil
  end

  local resp = client.request_sync('workspace/executeCommand', { command = 'vscode.java.startDebugSession', arguments = {} }, 15000, 0)

  if not resp then
    vim.notify('No response from jdtls for startDebugSession', vim.log.levels.ERROR)
    return nil
  end

  if resp.err then
    vim.notify('startDebugSession error: ' .. (resp.err.message or vim.inspect(resp.err)), vim.log.levels.ERROR)
    return nil
  end

  local port = resp.result
  if not port or port == '' or port == 0 then
    vim.notify('startDebugSession returned empty DAP port', vim.log.levels.ERROR)
    return nil
  end

  return port
end

local function vimspector_java_launch()
  local port = get_fresh_dap_port()
  if not port then
    return
  end

  -- optional: show port in message area for troubleshooting
  -- vim.notify("Java DAPPort=" .. tostring(port), vim.log.levels.INFO)

  vim.fn['vimspector#LaunchWithSettings'] { DAPPort = port }
end

vim.keymap.set('n', '<leader>dd', vimspector_java_launch, {
  buffer = true,
  silent = true,
  desc = 'Java Debug (vimspector) - fresh DAPPort from jdtls',
})
