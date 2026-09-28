// Main interactive application logic for walh-shell website

document.addEventListener("DOMContentLoaded", () => {
  initSiteTheme();
  initInstallSwitcher();
  initCopyButtons();
  initTerminalPlayground();
  initCatalog();
  initMobileNav();
});

/* =========================================================================
   Site Dark / Light Theme Management
   ========================================================================= */
function initSiteTheme() {
  const root = document.documentElement;
  const storageKey = "walh:site-theme";
  const savedTheme = localStorage.getItem(storageKey);
  const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");

  const applyTheme = (theme) => {
    root.dataset.theme = theme;
    localStorage.setItem(storageKey, theme);
    updateThemeIcon(theme);
  };

  const initialTheme = savedTheme || (mediaQuery.matches ? "dark" : "light");
  applyTheme(initialTheme);

  const toggleBtn = document.getElementById("themeToggle");
  if (toggleBtn) {
    toggleBtn.addEventListener("click", () => {
      const nextTheme = root.dataset.theme === "dark" ? "light" : "dark";
      applyTheme(nextTheme);
    });
  }

  mediaQuery.addEventListener("change", (e) => {
    if (!localStorage.getItem(storageKey)) {
      applyTheme(e.matches ? "dark" : "light");
    }
  });
}

function updateThemeIcon(theme) {
  const toggleBtn = document.getElementById("themeToggle");
  if (!toggleBtn) return;

  if (theme === "dark") {
    toggleBtn.innerHTML = `
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="5"/>
        <line x1="12" y1="1" x2="12" y2="3"/>
        <line x1="12" y1="21" x2="12" y2="23"/>
        <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/>
        <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/>
        <line x1="1" y1="12" x2="3" y2="12"/>
        <line x1="21" y1="12" x2="23" y2="12"/>
        <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/>
        <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>
      </svg>
    `;
    toggleBtn.setAttribute("aria-label", "Switch to light theme");
  } else {
    toggleBtn.innerHTML = `
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
      </svg>
    `;
    toggleBtn.setAttribute("aria-label", "Switch to dark theme");
  }
}

/* =========================================================================
   Install Switcher (Featuring zload)
   ========================================================================= */
function initInstallSwitcher() {
  const tabs = document.querySelectorAll(".install-tab");
  const codeEl = document.getElementById("installCode");
  const copyBtn = document.getElementById("installCopyBtn");
  if (!tabs.length || !codeEl || !copyBtn) return;

  const installSnippets = {
    zload: "zload casonadams/walh-shell",
    zinit: "zinit wait lucid for OMZL::key-bindings.zsh OMZL::history.zsh OMZP::git casonadams/walh-shell",
    omz: "git clone https://github.com/casonadams/walh-shell.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/walh-shell",
    manual: "source ~/.walh-shell/walh-shell.plugin.zsh",
    bash: "source ~/.walh-shell/profile_helper.sh"
  };

  tabs.forEach((tab) => {
    tab.addEventListener("click", () => {
      tabs.forEach((t) => t.classList.remove("active"));
      tab.classList.add("active");

      const key = tab.dataset.installTab || "zload";
      const cmd = installSnippets[key] || installSnippets.zload;

      codeEl.textContent = cmd;
      copyBtn.dataset.copy = cmd;
    });
  });
}

/* =========================================================================
   Universal Copy Buttons
   ========================================================================= */
function initCopyButtons() {
  document.addEventListener("click", (e) => {
    const btn = e.target.closest(".copy-btn");
    if (!btn) return;

    const textToCopy = btn.dataset.copy || btn.textContent.trim();
    if (!textToCopy) return;

    navigator.clipboard.writeText(textToCopy).then(() => {
      const originalHtml = btn.innerHTML;
      btn.classList.add("copied");
      btn.innerHTML = `
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="20 6 9 17 4 12"/>
        </svg>
        <span>Copied!</span>
      `;

      setTimeout(() => {
        btn.classList.remove("copied");
        btn.innerHTML = originalHtml;
      }, 1800);
    });
  });
}

/* =========================================================================
   Interactive Terminal Playground
   ========================================================================= */
let currentThemeSlug = "catppuccin-mocha";

function initTerminalPlayground() {
  const quickPills = document.querySelectorAll(".theme-pill-btn");
  quickPills.forEach((pill) => {
    pill.addEventListener("click", () => {
      const slug = pill.dataset.themeSlug;
      if (slug) applyTerminalTheme(slug);
    });
  });

  const toggleModeBtn = document.getElementById("terminalTogglePairBtn");
  if (toggleModeBtn) {
    toggleModeBtn.addEventListener("click", () => {
      const current = (window.WALH_THEMES || []).find((t) => t.slug === currentThemeSlug);
      if (current && current.pairSlug) {
        applyTerminalTheme(current.pairSlug);
      }
    });
  }

  // Initial apply
  applyTerminalTheme(currentThemeSlug);
}

function applyTerminalTheme(slug) {
  const themes = window.WALH_THEMES || [];
  const theme = themes.find((t) => t.slug === slug);
  if (!theme) return;

  currentThemeSlug = slug;
  const screen = document.getElementById("terminalScreen");
  if (!screen) return;

  // Apply CSS custom properties to terminal screen
  screen.style.setProperty("--term-bg", theme.background);
  screen.style.setProperty("--term-fg", theme.foreground);
  screen.style.setProperty("--term-c208", theme.color208);

  for (let i = 0; i < 16; i++) {
    const pad = String(i).padStart(2, "0");
    screen.style.setProperty(`--term-c${pad}`, theme.colors[i]);
  }

  // Update prompt command line in terminal
  const promptCmd = document.getElementById("termExecutedCmd");
  if (promptCmd) {
    promptCmd.textContent = `walh ${theme.slug}`;
  }

  // Update output status line
  const outputMsg = document.getElementById("termOutputStatus");
  if (outputMsg) {
    const fgbg = theme.mode === "dark" ? "15;0" : "0;15";
    outputMsg.textContent = `[walh] Applied ${theme.slug} (${theme.mode}) · COLORFGBG="${fgbg}" · color00=${theme.colors[0]} color08=${theme.colors[8]}`;
  }

  // Update titlebar meta
  const metaBadge = document.getElementById("termMetaBadge");
  if (metaBadge) {
    metaBadge.textContent = `${theme.slug} (${theme.mode})`;
  }

  // Update footer active info
  const footerSlug = document.getElementById("termFooterSlug");
  if (footerSlug) footerSlug.textContent = theme.slug;

  const footerMode = document.getElementById("termFooterMode");
  if (footerMode) {
    footerMode.textContent = theme.mode;
    footerMode.className = `terminal-mode-badge mode-${theme.mode}`;
  }

  const footerPairBtn = document.getElementById("terminalTogglePairBtn");
  if (footerPairBtn) {
    if (theme.pairSlug) {
      footerPairBtn.style.display = "inline-flex";
      footerPairBtn.textContent = `Switch to ${theme.pairSlug}`;
    } else {
      footerPairBtn.style.display = "none";
    }
  }

  const termCopyBtn = document.getElementById("termCopyBtn");
  if (termCopyBtn) {
    const cmd = `walh ${theme.slug}`;
    termCopyBtn.dataset.copy = cmd;
    const btnSpan = termCopyBtn.querySelector("span");
    if (btnSpan) btnSpan.textContent = `Copy: ${cmd}`;
  }

  // Update quick pills active state
  document.querySelectorAll(".theme-pill-btn").forEach((pill) => {
    pill.classList.toggle("active", pill.dataset.themeSlug === slug);
  });

  // Update catalog card active state
  document.querySelectorAll(".theme-card").forEach((card) => {
    card.classList.toggle("active-preview", card.dataset.themeSlug === slug);
  });
}

/* =========================================================================
   Theme Catalog / Explorer
   ========================================================================= */
let activeModeFilter = "all";
let searchQuery = "";

function initCatalog() {
  const container = document.getElementById("themeGrid");
  const searchInput = document.getElementById("catalogSearch");
  const filterBtns = document.querySelectorAll(".filter-btn");
  if (!container) return;

  renderCatalog();

  if (searchInput) {
    searchInput.addEventListener("input", (e) => {
      searchQuery = e.target.value.toLowerCase().trim();
      renderCatalog();
    });
  }

  filterBtns.forEach((btn) => {
    btn.addEventListener("click", () => {
      filterBtns.forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");
      activeModeFilter = btn.dataset.filter || "all";
      renderCatalog();
    });
  });
}

function renderCatalog() {
  const container = document.getElementById("themeGrid");
  const counter = document.getElementById("catalogCount");
  if (!container) return;

  const themes = window.WALH_THEMES || [];
  const filtered = themes.filter((t) => {
    const matchesMode = activeModeFilter === "all" || t.mode === activeModeFilter;
    const matchesSearch =
      !searchQuery ||
      t.slug.toLowerCase().includes(searchQuery) ||
      t.family.toLowerCase().includes(searchQuery);
    return matchesMode && matchesSearch;
  });

  if (counter) {
    counter.textContent = `Showing ${filtered.length} of ${themes.length} themes`;
  }

  if (filtered.length === 0) {
    container.innerHTML = `
      <div style="grid-column: 1 / -1; text-align: center; padding: 3rem; color: var(--text-muted);">
        No themes found matching "<strong>${escapeHtml(searchQuery)}</strong>".
      </div>
    `;
    return;
  }

  container.innerHTML = filtered
    .map((theme) => {
      const isActive = theme.slug === currentThemeSlug;
      const chips = [
        theme.colors[1],
        theme.colors[2],
        theme.colors[3],
        theme.colors[4],
        theme.colors[5],
        theme.colors[6],
        theme.colors[0],
        theme.colors[8]
      ];

      const pairBadge = theme.pairSlug
        ? `<button class="pair-badge-btn" data-pair-slug="${escapeHtml(theme.pairSlug)}" title="Switch to pair: ${escapeHtml(theme.pairSlug)}" aria-label="Switch to pair ${escapeHtml(theme.pairSlug)}">⇌ ${escapeHtml(theme.pairSlug)}</button>`
        : "";

      return `
      <div class="theme-card ${isActive ? "active-preview" : ""}" data-theme-slug="${escapeHtml(theme.slug)}">
        <div class="theme-card-header">
          <span class="theme-card-title">${escapeHtml(theme.slug)}</span>
          <div style="display: flex; align-items: center; gap: 0.35rem;">
            ${pairBadge}
            <span class="terminal-mode-badge mode-${escapeHtml(theme.mode)}">${escapeHtml(theme.mode)}</span>
          </div>
        </div>

        <div class="theme-card-palette">
          <div class="palette-preview-bar" style="background-color: ${escapeHtml(theme.background)}; color: ${escapeHtml(theme.foreground)};">
            <span>${escapeHtml(theme.family)}</span>
            <span style="font-size: 0.72rem; opacity: 0.85;">${escapeHtml(theme.background)}</span>
          </div>
          <div class="palette-chips-row">
            ${chips.map((c) => `<div class="palette-chip" style="background-color: ${escapeHtml(c)};" title="${escapeHtml(c)}"></div>`).join("")}
          </div>
        </div>

        <div class="theme-card-footer">
          <code class="card-cmd-badge">walh ${escapeHtml(theme.slug)}</code>
          <button class="copy-btn" data-copy="walh ${escapeHtml(theme.slug)}" aria-label="Copy activation command" title="Copy command">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect x="9" y="9" width="13" height="13" rx="2" ry="2"/>
              <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/>
            </svg>
          </button>
        </div>
      </div>
    `;
    })
    .join("");

  // Add click listeners to cards
  container.querySelectorAll(".theme-card").forEach((card) => {
    card.addEventListener("click", (e) => {
      if (e.target.closest(".copy-btn")) return;
      const pairBtn = e.target.closest(".pair-badge-btn");
      if (pairBtn) {
        e.stopPropagation();
        const pairSlug = pairBtn.dataset.pairSlug;
        if (pairSlug) applyTerminalTheme(pairSlug);
        return;
      }

      const slug = card.dataset.themeSlug;
      if (slug) {
        applyTerminalTheme(slug);
        const termElement = document.getElementById("terminalContainer");
        if (termElement && window.innerWidth < 800) {
          termElement.scrollIntoView({ behavior: "smooth", block: "nearest" });
        }
      }
    });
  });
}

function escapeHtml(str) {
  if (!str) return "";
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

/* =========================================================================
   Mobile Navigation Drawer
   ========================================================================= */
function initMobileNav() {
  const toggleBtn = document.getElementById("mobileNavBtn");
  const drawer = document.getElementById("mobileNavDrawer");
  if (!toggleBtn || !drawer) return;

  toggleBtn.addEventListener("click", () => {
    const isOpen = drawer.classList.toggle("open");
    toggleBtn.setAttribute("aria-expanded", String(isOpen));
  });

  drawer.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", () => {
      drawer.classList.remove("open");
      toggleBtn.setAttribute("aria-expanded", "false");
    });
  });
}
