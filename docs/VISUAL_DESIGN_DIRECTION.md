# As Mitra Game — Visual Design Direction

Status: direction for later art. Milestone 8 does not add finished models.

## Identity

As Mitra Game is a bright, colorful, cheerful, stylized 3D supermarket. The store should feel like a welcoming Indian-inspired market: warm light, clear departments, and friendly shapes. It should stay readable on a phone.

The look is stylized. It is not a dark industrial space, a grey-only blockout as the final art, or a photoreal render.

## Originality

Reference images are inspiration for mood only. As Mitra does not copy characters, layouts, artwork, interface, branding, logos, text, or environment designs from another game or store.

Names, colors, signs, products, and Chiku are original to this project.

## Chiku

Chiku is the game's rabbit mascot, not a shopper and not a random NPC. Chiku can later welcome the player, explain stocking, mention low stock, notice a customer, celebrate a sale, and mark store growth.

Those lines live in `lib/game/mascot/chiku.dart`. No system speaks them yet. Chiku has no finished model. A later scene can build Chiku with the same placeholder figure used for customers (`FigureAccent.ears`), then replace that figure with the real model.

Chiku is not referenced by the customer manager, shelves, or checkout.

## Supermarket

The blockout should grow into a lively store:

- a clear entrance and a colorful awning
- warm interior light
- separate areas for produce, groceries, dairy, snacks, and personal care
- readable shelves and product variety
- a checkout, a back room, signs, baskets, and simple decoration

The first dressing pass adds striped awnings, a color board for dairy, groceries, snacks, personal care, and produce, a produce table with baskets, and a short row of bunting. The boards are color marks. They do not copy sign lettering. The floor plan is still the blockout.

## Products and customers

Products stay simple colored shapes until a later art pass. Packaging should be colorful and distinct by department.

Customers are placeholders: a body, a head, and one accent (cap or sash). Regular, Quick Shopper, and Slow Shopper use different colors. The customer record does not know about scene nodes. `CustomerPresenter` only copies position and facing onto the figure.

## UI

Later interface work should be large, readable, colorful, and easy to tap in landscape. Chiku can appear in tutorials, tips, and rewards. The current HUD is not being redesigned. The customer readout is a small temporary debug line.

## Lighting and performance

Prefer one warm directional light, flat materials, and soft contrast. Avoid dark scenes, dirty photoreal textures, heavy shaders, extra post-processing, and extra lights.

Reuse materials. Keep extra nodes small. Do not rebuild Flutter widgets every frame. Three active customers is the current cap.

## Later art

1. Richer department displays on the color boards and produce table already in the blockout.
2. Chiku's model and the first spoken prompts.
3. Customer models and a short walk cycle, using the same presenter seam.
4. UI panels that match this direction.

Finished animation, audio, and a navigation mesh are out of scope until their own milestones.
