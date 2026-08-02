/* =========================================================
   Simon Kamua — Industrial Automation Portfolio
   Shared website behaviour
   ========================================================= */

"use strict";

document.addEventListener("DOMContentLoaded", () => {
  const body = document.body;
  const navToggle = document.querySelector(".nav-toggle");
  const siteNav = document.querySelector(".site-nav");
  const navLinks = siteNav
    ? Array.from(siteNav.querySelectorAll("a"))
    : [];

  /* ---------- Mobile navigation ---------- */

  function setNavigationState(isOpen) {
    if (!navToggle || !siteNav) return;

    siteNav.classList.toggle("is-open", isOpen);
    body.classList.toggle("nav-open", isOpen);

    navToggle.setAttribute("aria-expanded", String(isOpen));
    navToggle.setAttribute(
      "aria-label",
      isOpen ? "Close navigation menu" : "Open navigation menu"
    );
  }

  if (navToggle && siteNav) {
    setNavigationState(false);

    navToggle.addEventListener("click", () => {
      const isOpen = siteNav.classList.contains("is-open");
      setNavigationState(!isOpen);
    });

    siteNav.addEventListener("click", (event) => {
      const selectedLink = event.target.closest("a");

      if (selectedLink) {
        setNavigationState(false);
      }
    });

    document.addEventListener("click", (event) => {
      const clickedOutsideNavigation =
        !siteNav.contains(event.target) &&
        !navToggle.contains(event.target);

      if (
        clickedOutsideNavigation &&
        siteNav.classList.contains("is-open")
      ) {
        setNavigationState(false);
      }
    });

    document.addEventListener("keydown", (event) => {
      if (
        event.key === "Escape" &&
        siteNav.classList.contains("is-open")
      ) {
        setNavigationState(false);
        navToggle.focus();
      }
    });

    const desktopView = window.matchMedia("(min-width: 901px)");

    const handleDesktopView = (event) => {
      if (event.matches) {
        setNavigationState(false);
      }
    };

    if (typeof desktopView.addEventListener === "function") {
      desktopView.addEventListener("change", handleDesktopView);
    } else {
      desktopView.addListener(handleDesktopView);
    }
  }

  /* ---------- Automatic footer year ---------- */

  const yearElements = document.querySelectorAll(
    "[data-current-year], #current-year"
  );

  yearElements.forEach((element) => {
    element.textContent = new Date().getFullYear();
  });

  /* ---------- Active navigation states ---------- */

  function normalisePath(pathname) {
    const cleanPath = pathname
      .replace(/index\.html$/i, "")
      .replace(/\/+$/, "");

    return cleanPath || "/";
  }

  const currentPath = normalisePath(window.location.pathname);

  const sectionLinks = navLinks
    .map((link) => {
      const url = new URL(link.href, window.location.href);
      const targetId = decodeURIComponent(url.hash.slice(1));
      const targetSection = targetId
        ? document.getElementById(targetId)
        : null;

      return {
        link,
        url,
        targetSection
      };
    })
    .filter(
      (item) =>
        item.targetSection &&
        normalisePath(item.url.pathname) === currentPath
    );

  function activateNavigationLink(activeLink) {
    navLinks.forEach((link) => {
      link.classList.remove("active");
      link.removeAttribute("aria-current");
    });

    if (activeLink) {
      activeLink.classList.add("active");
      activeLink.setAttribute("aria-current", "location");
    }
  }

  const currentPageLink = navLinks.find((link) => {
    const url = new URL(link.href, window.location.href);

    return (
      !url.hash &&
      normalisePath(url.pathname) === currentPath
    );
  });

  if (currentPageLink) {
    activateNavigationLink(currentPageLink);
  }

  sectionLinks.forEach(({ link }) => {
    link.addEventListener("click", () => {
      activateNavigationLink(link);
    });
  });

  if ("IntersectionObserver" in window && sectionLinks.length > 0) {
    const sectionObserver = new IntersectionObserver(
      (entries) => {
        const visibleSections = entries
          .filter((entry) => entry.isIntersecting)
          .sort(
            (first, second) =>
              second.intersectionRatio - first.intersectionRatio
          );

        if (visibleSections.length === 0) return;

        const activeSection = visibleSections[0].target;

        const matchingItem = sectionLinks.find(
          ({ targetSection }) => targetSection === activeSection
        );

        if (matchingItem) {
          activateNavigationLink(matchingItem.link);
        }
      },
      {
        rootMargin: "-25% 0px -60% 0px",
        threshold: [0.1, 0.25, 0.5]
      }
    );

    sectionLinks.forEach(({ targetSection }) => {
      sectionObserver.observe(targetSection);
    });
  }
});
