return {
   'VonHeikemen/lsp-zero.nvim',
   branch = 'v4.x',
   dependencies = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},
      {'lvimuser/lsp-inlayhints.nvim'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},
      {
         "folke/lazydev.nvim",
         ft = "lua", --only load on lua files
         opts = {
            library = {
               "/luvit-meta/library",
               -- Library items can be absolute paths
               -- "~/projects/my-awesome-lib",
               -- Or relative, which means they will be resolved as a plugin
               -- "LazyVim",
               -- When relative, you can also provide a path to the library in the plugin
            },
         },
      },
      {
         "Bilal2453/luvit-meta", lazy = true, --optional `vim.uv` typings
      },
      {'mfussenegger/nvim-dap',
         dependencies = {
            "jay-babu/mason-nvim-dap.nvim",
            "rcarriga/nvim-dap-ui",
         }
      },
      {'SmiteshP/nvim-navic'},
      -- Autocompletion
      {
         'hrsh7th/nvim-cmp',
         opts = function(_, opts)
            opts.sources = opts.sources or {}
            table.insert(opts.sources, {
               name = "lazydev",
               group_index =  0 -- to skip loading luals completions
            })
         end,
      },     -- Required
      {'hrsh7th/cmp-nvim-lsp'}, -- Required
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'L3MON4D3/LuaSnip',
         dependencies = {
            {'rafamadriz/friendly-snippets'},
            { 'saadparwaiz1/cmp_luasnip' }
         },
         version = "v2.*", -- Replace <CurrentMajor> by the latest released major
         build = "make install_jsregexp",
      },     -- Required
      {"jay-babu/mason-null-ls.nvim",
         event = { "BufReadPre", "BufNewFile" },
         dependencies = {"nvimtools/none-ls.nvim"},
         config = function()
            require("mason-null-ls").setup({
               ensure_installed = {
                  -- Opt to list sources here, when available in mason.
               },
               automatic_installation = false,
               handlers = {},
            })
         end,
      },
   },
   config = function()
      local cmp = require('cmp')
      local lsp_zero = require("lsp-zero")
      local cmp_select = {behavior = cmp.SelectBehavior.Select}
      local lspconfig_defaults = require('lspconfig').util.default_config
      lspconfig_defaults.capabilities = vim.tbl_deep_extend(
         'force',
         lspconfig_defaults.capabilities,
         require('cmp_nvim_lsp').default_capabilities()
      )


      cmp.setup({
         sources = {
            {name = 'path'},
            {name = 'nvim_lsp'},
            {name = 'nvim_lua'},
            {name = 'luasnip', keyword_length = 2},
            {name = 'buffer', keyword_length = 3},
         },
         snippet = {
            expand = function(args)
               require('luasnip').lsp_expand(args.body)
            end
         },
         mapping = cmp.mapping.preset.insert({
            ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
            ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ['<C-Space>'] = cmp.mapping.complete(),
         }),
      })

      local lsp_attach = function(client, bufnr)
         local opts = {buffer = bufnr, remap = false}

         vim.keymap.set("n", "gdf", function() vim.lsp.buf.definition() end, opts)
         vim.keymap.set("n", "gdc", function() vim.lsp.buf.declaration() end, opts)
         vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
         vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
         vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
         vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
         vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
         vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
         vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
         vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
         vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)

         if client.server_capabilities.documentSymbolProvider then
            require('nvim-navic').attach(client, bufnr)
         end

      end

      lsp_zero.extend_lspconfig({
         capabilities = require('cmp_nvim_lsp').default_capabilities(),
         lsp_attach = lsp_attach,
         float_border = 'rounded',
         sign_text = true,
      })

      -- Set navic highlight groups
      vim.api.nvim_set_hl(0, "NavicIconsFile",          {default = true, bg = "#282828", fg = "#EBDBB2"})
      vim.api.nvim_set_hl(0, "NavicIconsModule",        {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsNamespace",     {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsPackage",       {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsClass",         {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsMethod",        {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsProperty",      {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsField",         {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsConstructor",   {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsEnum",          {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsInterface",     {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsFunction",      {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsVariable",      {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsConstant",      {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsString",        {default = true, bg = "#282828", fg = "#D3869B"})
      vim.api.nvim_set_hl(0, "NavicIconsNumber",        {default = true, bg = "#282828", fg = "#8F3F71"})
      vim.api.nvim_set_hl(0, "NavicIconsBoolean",       {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsArray",         {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsObject",        {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsKey",           {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsNull",          {default = true, bg = "#282828", fg = "#928374"})
      vim.api.nvim_set_hl(0, "NavicIconsEnumMember",    {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsStruct",        {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsEvent",         {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsOperator",      {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicIconsTypeParameter", {default = true, bg = "#282828", fg = "#83A598"})
      vim.api.nvim_set_hl(0, "NavicText",               {default = true, bg = "#282828", fg = "#EBDBB2"})
      vim.api.nvim_set_hl(0, "NavicSeparator",          {default = true, bg = "#282828", fg = "#504945"})
      require('nvim-navic').setup({
         highlight = true,
      })

      require('mason').setup({})
      require('mason-lspconfig').setup({
         ensure_installed = {},
         automatic_installation = true,
         handlers = {
            function (server_name)
               require('lspconfig')[server_name].setup({})
            end,
            lua_ls = function()
               local lua_opts = lsp_zero.nvim_lua_ls()
               require('lspconfig').lua_ls.setup(lua_opts)
            end,

         }
      })
      require('mason-nvim-dap').setup({
         ensure_installed = {},
         automatic_installation = true,
         handlers = {
            function(config)
               require("mason-nvim-dap").default_setup(config)
            end,
         }, -- sets up dap in the predefined manner
      })
    
      require('luasnip.loaders.from_vscode').lazy_load()

   end,
}
