// =============================================================================
// loadProducts, add normalizeProduct, and update renderProducts 
// Configuration - fill these in after `terraform apply`:
//   terraform output product_alb_dns
//   terraform output order_alb_dns
// Using plain http:// ALB DNS names for this demo. If you add ACM
// certificates + HTTPS listeners later, use https:// here instead.
// =============================================================================
const CONFIG = {
  PRODUCT_API_URL: "shopeasy-dev-order-alb-1066274269.us-east-1.elb.amazonaws.com",
  ORDER_API_URL: "shopeasy-dev-product-alb-1503009282.us-east-1.elb.amazonaws.com",
};

// Fallback catalog shown if the live API isn't reachable yet, so my
// portfolio demo still looks complete even with the backend switched off.
const FALLBACK_PRODUCTS = [
    {
    productId: "prod-001",
    sku: "SKU-10221",
    name: "Garden Hose 20m",
    price: 45.99,
    unit: "each",
    category: "hose",
    image: "prod-001.jpg",
    stock: 24,
    description: "20m UV-resistant PVC hose"
  },
  {
    productId: "prod-002",
    sku: "SKU-10238",
    name: "Cordless Drill 18V",
    price: 129.00,
    unit: "each",
    category: "drill",
    image: "prod-002.jpg",
    stock: 15,
    description: "18V li-ion, 2 batteries included"
  },
  {
    productId: "prod-003",
    sku: "SKU-10254",
    name: "Paint Roller Set",
    price: 18.50,
    unit: "set",
    category: "paint",
    image: "prod-003.jpg",
    stock: 60,
    description: "230mm roller, tray + 2 covers"
  },
  {
    productId: "prod-004",
    sku: "SKU-10267",
    name: "Claw Hammer 450g",
    price: 24.00,
    unit: "each",
    category: "hammer",
    image: "prod-004.jpg",
    stock: 48,
    description: "16oz fibreglass handle"
  },
  {
    productId: "prod-005",
    sku: "SKU-10281",
    name: "Spirit Level 600mm",
    price: 32.90,
    unit: "each",
    category: "level",
    image: "prod-005.jpg",
    stock: 30,
    description: "Aluminium body, 3 vials"
  },
  {
    productId: "prod-006",
    sku: "SKU-10299",
    name: "Work Gloves - Pair",
    price: 12.00,
    unit: "pair",
    category: "gloves",
    image: "prod-006.jpg",
    stock: 100,
    description: "Synthetic leather, reinforced palm"
  },
{
    productId: "prod-007",
    sku: "SKU-10310",
    name: "Safety Goggles",
    price: 8.50,
    unit: "each",
    category: "default",
    image: "prod-007.jpg",
    stock: 75,
    description: "Clear anti-fog safety goggles"
  }
];

const ICONS = {
  hose: '<path d="M4 8h6a4 4 0 0 1 4 4v0a4 4 0 0 0 4 4h2" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round"/><circle cx="4" cy="8" r="2" stroke="currentColor" stroke-width="2" fill="none"/><circle cx="20" cy="16" r="2" stroke="currentColor" stroke-width="2" fill="none"/>',
  drill: '<rect x="3" y="10" width="11" height="6" rx="1.5" stroke="currentColor" stroke-width="2" fill="none"/><path d="M14 12h4l3 2-3 2h-4" stroke="currentColor" stroke-width="2" fill="none" stroke-linejoin="round"/>',
  paint: '<rect x="7" y="3" width="7" height="5" rx="1" stroke="currentColor" stroke-width="2" fill="none"/><path d="M8 8v3a2 2 0 0 0 2 2h0a2 2 0 0 1 2 2v6" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round"/><rect x="9" y="12" width="6" height="9" rx="1.5" stroke="currentColor" stroke-width="2" fill="none"/>',
  hammer: '<path d="M14 5l5 5-2 2-5-5z" stroke="currentColor" stroke-width="2" fill="none" stroke-linejoin="round"/><path d="M13 8L4 17l3 3 9-9" stroke="currentColor" stroke-width="2" fill="none" stroke-linejoin="round"/>',
  level: '<rect x="3" y="10" width="18" height="6" rx="1.5" stroke="currentColor" stroke-width="2" fill="none"/><circle cx="12" cy="13" r="1.6" stroke="currentColor" stroke-width="1.6" fill="none"/>',
  gloves: '<path d="M7 21V11a2 2 0 0 1 4 0v3M11 14v-5a2 2 0 0 1 4 0v5M15 14v-3a2 2 0 0 1 4 0v6a4 4 0 0 1-4 4H9a4 4 0 0 1-4-4v-3l2-2" stroke="currentColor" stroke-width="1.8" fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
  default: '<rect x="4" y="4" width="16" height="16" rx="3" stroke="currentColor" stroke-width="2" fill="none"/>',
};

const state = {
  products: [],
  cart: {},
};

const el = (sel) => document.querySelector(sel);
const money = (n) => `$${Number(n).toFixed(2)}`;

// =============================================================================
// Normalize both live API data and fallback data into one shape
// =============================================================================
function normalizeProduct(p) {
  return {
    id: p.productId || p.id,
    productId: p.productId || p.id,
    sku: p.sku || p.productId || p.id || "",
    name: p.name,
    description: p.description || "",
    price: Number(p.price),
    currency: p.currency || "USD",
    unit: p.unit || "each",
    category: p.category || "default",
    stock: typeof p.stock === "number" ? p.stock : null,
    imageUrl: p.imageUrl || (p.image ? `images/${p.image}` : ""),
    isActive: p.isActive !== false
  };
}

async function loadProducts() {
  try {
    const res = await fetch(`${CONFIG.PRODUCT_API_URL}/products`, { mode: "cors" });
    if (!res.ok) throw new Error(`API returned ${res.status}`);
    const data = await res.json();
    state.products = data.products || [];
    el("#apiNotice").hidden = true;
  } catch (err) {
    state.products = FALLBACK_PRODUCTS;
    const notice = el("#apiNotice");
    notice.textContent = "Showing a cached catalog — connect the live product-service API to see real-time stock.";
    notice.hidden = false;
  }
  renderProducts();
}

async function loadProducts() {
  try {
    const res = await fetch(`${CONFIG.PRODUCT_API_URL}/products`, { mode: "cors" });
    if (!res.ok) throw new Error(`API returned ${res.status}`);
    const data = await res.json();
    const raw = data.products || data || [];
    state.products = raw.map(normalizeProduct);
    el("#apiNotice").hidden = true;
  } catch (err) {
    state.products = FALLBACK_PRODUCTS.map(normalizeProduct);
    const notice = el("#apiNotice");
    notice.textContent = "Showing a cached catalog — connect the live product-service API to see real-time stock.";
    notice.hidden = false;
  }
  renderProducts();
}

function renderProducts() {
  const grid = el("#productGrid");
  grid.innerHTML = "";

  state.products.forEach((p) => {
    const iconPath = ICONS[p.category] || ICONS.default;
    const lowStock = typeof p.stock === "number" && p.stock < 10;

    const card = document.createElement("article");
    card.className = "card";
    card.innerHTML = `
      <div class="card-media">
        <div class="card-icon"><svg viewBox="0 0 24 24">${iconPath}</svg></div>
        ${p.imageUrl
          ? `<img src="${p.imageUrl}" alt="${p.name}" loading="lazy" onerror="this.style.display='none'">`
          : ""}
      </div>
      <h3>${p.name}</h3>
      ${p.description ? `<p class="desc">${p.description}</p>` : ""}
      <div class="card-meta">
        ${p.sku ? `<span class="meta-sku">${p.sku}</span>` : ""}
        ${typeof p.stock === "number"
          ? `<span class="meta-stock${lowStock ? " low" : ""}">${p.stock} in stock</span>`
          : ""}
      </div>
      <p class="unit">Sold ${p.unit}</p>
      <p class="price">${money(p.price)}</p>
      <div class="card-actions">
        <div class="qty">
          <button type="button" data-action="dec" aria-label="Decrease quantity">&minus;</button>
          <span data-role="qty">1</span>
          <button type="button" data-action="inc" aria-label="Increase quantity">+</button>
        </div>
        <button type="button" class="add-btn" data-action="add">Add to order</button>
      </div>
    `;

    let qty = 1;
    const qtyLabel = card.querySelector('[data-role="qty"]');
    card.querySelector('[data-action="dec"]').addEventListener("click", () => {
      qty = Math.max(1, qty - 1);
      qtyLabel.textContent = qty;
    });
    card.querySelector('[data-action="inc"]').addEventListener("click", () => {
      qty = Math.min(99, qty + 1);
      qtyLabel.textContent = qty;
    });

    const addBtn = card.querySelector('[data-action="add"]');
    addBtn.addEventListener("click", () => {
      addToCart(p, qty);
      addBtn.textContent = "Added";
      addBtn.classList.add("added");
      setTimeout(() => {
        addBtn.textContent = "Add to order";
        addBtn.classList.remove("added");
      }, 900);
    });

    grid.appendChild(card);
  });
}

function addToCart(product, qty) {
  if (state.cart[product.id]) {
    state.cart[product.id].qty += qty;
  } else {
    state.cart[product.id] = { product, qty };
  }
  renderCart();
  bumpCartCount();
}

function removeFromCart(id) {
  delete state.cart[id];
  renderCart();
}

function cartEntries() {
  return Object.values(state.cart);
}

function renderCart() {
  const entries = cartEntries();
  const count = entries.reduce((sum, e) => sum + e.qty, 0);
  el("#cartCount").textContent = count;

  el("#cartEmpty").hidden = entries.length > 0;
  const list = el("#cartList");
  list.innerHTML = "";

  let total = 0;
  entries.forEach(({ product, qty }) => {
    total += product.price * qty;
    const li = document.createElement("li");
    li.className = "cart-item";
    li.innerHTML = `
      <div>
        <div class="cart-item-name">${product.name}</div>
        <div class="cart-item-meta">${qty} &times; ${money(product.price)}</div>
      </div>
      <button type="button" class="cart-item-remove" data-id="${product.id}">Remove</button>
    `;
    li.querySelector(".cart-item-remove").addEventListener("click", () => removeFromCart(product.id));
    list.appendChild(li);
  });

  el("#cartTotal").textContent = money(total);
  el("#placeOrderBtn").disabled = entries.length === 0;
}

function bumpCartCount() {
  const badge = el("#cartCount");
  badge.classList.add("bump");
  setTimeout(() => badge.classList.remove("bump"), 220);
}

function openCart() {
  el("#cartDrawer").classList.add("open");
  el("#cartOverlay").classList.add("open");
}
function closeCart() {
  el("#cartDrawer").classList.remove("open");
  el("#cartOverlay").classList.remove("open");
}

async function placeOrder() {
  const entries = cartEntries();
  if (entries.length === 0) return;

  const statusEl = el("#orderStatus");
  const btn = el("#placeOrderBtn");
  btn.disabled = true;
  statusEl.className = "order-status";
  statusEl.textContent = "Placing your order...";

  try {
    const results = await Promise.all(
      entries.map(({ product, qty }) =>
        fetch(`${CONFIG.ORDER_API_URL}/orders`, {
          method: "POST",
          mode: "cors",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            product_id: product.id,
            quantity: qty
          }),
        }).then((r) => {
          if (!r.ok) throw new Error(`order-service returned ${r.status}`);
          return r.json();
        })
      )
    );

    const refs = results.map((r) => r.order.transaction_id.slice(0, 8)).join(", ");
    statusEl.textContent = `Order placed. Reference: ${refs}. Show this at the counter.`;
    statusEl.className = "order-status success";
    state.cart = {};
    renderCart();
  } catch (err) {
    statusEl.textContent = "Couldn't reach order-service right now. Check the ECS service is running and try again.";
    statusEl.className = "order-status error";
    btn.disabled = false;
  }
}

el("#cartToggle").addEventListener("click", openCart);
el("#cartClose").addEventListener("click", closeCart);
el("#cartOverlay").addEventListener("click", closeCart);
el("#placeOrderBtn").addEventListener("click", placeOrder);
document.addEventListener("keydown", (e) => {
  if (e.key === "Escape") closeCart();
});

loadProducts();
