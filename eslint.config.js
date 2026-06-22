import js from "@eslint/js";
import globals from "globals";

export default [
  {
    ignores: ["dist/", "build/", "node_modules/", "coverage/"]
  },

  {
    files: ["**/*.{js,mjs,cjs}"],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      globals: {
        ...globals.node
      },
    },
    rules: {
      ...js.configs.recommended.rules,
      "no-console": "warn",
      "no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
      "prefer-const": "error", 
      "no-process-exit": "off",
    },
  }
];
