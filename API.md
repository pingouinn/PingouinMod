# PingouinMod Documentation

## Module `BarrierOpener.lua`

### Fonction `BarrierOpener.OpenBarriers(closeWhenFar)`

Opens nearby barriers and optionally closes them when the player moves away.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `closeWhenFar` | `boolean` | If true, barriers will close when the player is far away. |

**Returns :**

- `boolean` : True if at least one barrier was found and processed, false if no barriers were found, nil if the player is not in a vehicle.

---

### Fonction `StartBarrierSearch()`

Starts the barrier search loop.

---

## Module `CollisionDeactivator.lua`

### Fonction `CollisionDeactivator.ToggleElementCollisionInFront(verbose)`

TODO : When collision deactivated, the entity should be added to a list of entities with disabled collision TODO : Find a way to detect back via raycast disabled collision entities Toggles the collision of the element in front of the player.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `verbose` | `boolean` | If true, prints detailed information about the hit entity and its resolved target. |

---

## Module `Constants.lua`

### Struct / Class `NativeUIPathsConstants`

| Field | Type | Description |
| :--- | :--- | :--- |
| `BACKGROUND_CLASS` | `string` | Unreal Blueprint path for the background region widget |
| `BUTTON_CLASS` | `string` | Unreal Blueprint path for the base button widget |
| `SWITCH_CLASS` | `string` | Unreal Blueprint path for the switch/toggle button widget |
| `TEXT_CLASS` | `string` | Unreal Blueprint path for the settings text widget |
| `TITLE_CLASS` | `string` | Unreal Blueprint path for the HUD mission title widget |
| `SLIDER_CLASS` | `string` | Unreal Blueprint path for the slider widget |
| `TEXTBOX_CLASS` | `string` | Unreal class path for editable text boxes |
| `HORIZONTAL_BOX_CLASS` | `string` | Unreal UMG class path for horizontal box containers |
| `VERTICAL_BOX_CLASS` | `string` | Unreal UMG class path for vertical box containers |
| `SIZE_BOX_CLASS` | `string` | Unreal UMG class path for size box containers |
| `SPACER_CLASS` | `string` | Unreal UMG class path for spacer widgets |
| `FONT_AFACAD` | `string` | Unreal asset path for the Afacad font family |
| `WIDGET_LIBRARY` | `string` | Unreal default object path for WidgetBlueprintLibrary |
| `BUTTON_CLICK_FUNCTION` | `string` | Unreal function path handling button click events |

---

### Struct / Class `NativeUILayoutConstants`

| Field | Type | Description |
| :--- | :--- | :--- |
| `HORIZONTAL_FILL` | `integer` | Horizontal alignment setting: fill available space |
| `HORIZONTAL_LEFT` | `integer` | Horizontal alignment setting: align to the left |
| `HORIZONTAL_CENTER` | `integer` | Horizontal alignment setting: align to the center |
| `HORIZONTAL_RIGHT` | `integer` | Horizontal alignment setting: align to the right |
| `VERTICAL_FILL` | `integer` | Vertical alignment setting: fill available space |
| `VERTICAL_TOP` | `integer` | Vertical alignment setting: align to the top |
| `VERTICAL_CENTER` | `integer` | Vertical alignment setting: align to the center |
| `VERTICAL_BOTTOM` | `integer` | Vertical alignment setting: align to the bottom |
| `SIZE_AUTO` | `integer` | Sizing rule: automatically adapt to content size |
| `SIZE_FILL` | `integer` | Sizing rule: stretch and fill parent container |

---

### Struct / Class `NativeUIVisibilityConstants`

| Field | Type | Description |
| :--- | :--- | :--- |
| `VISIBLE` | `integer` | UMG Slate visibility state: visible |
| `HIDDEN` | `integer` | UMG Slate visibility state: hidden |

---

### Struct / Class `NativeUIInputConstants`

| Field | Type | Description |
| :--- | :--- | :--- |
| `MOUSE_LOCK_DO_NOT_LOCK` | `integer` | Viewport mouse capture mode: do not lock mouse cursor |

---

### Struct / Class `NativeUIConstants`

| Field | Type | Description |
| :--- | :--- | :--- |
| `Paths` | `NativeUIPathsConstants` | Blueprint and class asset paths for UI widgets |
| `Layout` | `NativeUILayoutConstants` | Alignment and sizing enumeration constants |
| `Visibility` | `NativeUIVisibilityConstants` | Slate visibility states for widgets |
| `Input` | `NativeUIInputConstants` | Mouse lock behavior constants |

---

### Struct / Class `Constants`

| Field | Type | Description |
| :--- | :--- | :--- |
| `STATIC_MESH_ACTOR_CLASS_PATH` | `string` | Class path used to resolve StaticMeshActor instances |
| `STATIC_MESH_CLASS_PATH` | `string` | Class path used to resolve StaticMesh assets |
| `STATIC_MESH_COMPONENT_CLASS_PATH` | `string` | Class path used to resolve StaticMeshComponent instances |
| `TRACE_DISTANCE` | `number` | Default raycast trace length in Unreal units |

---

## Module `DevUI.lua`

### Fonction `BuildDashboard()`

Builds the development Dashboard used to exercise NativeUI components.

---

## Module `DisableWorldBoundaries.lua`

### Fonction `WorldBoundaries.DisableAllBlockingVolumes()`

Disables all BlockingVolume actors in the world to remove world boundaries. Also deletes specific actors that are known to enforce world boundaries, such as "BP_PCGSplineFence_C".

---

## Module `EntityOutline.lua`

### Fonction `IsUnsupportedCustomDepthError(errorMessage)`

Checks if an error message indicates an unsupported custom depth error.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `errorMessage` | `string` | The error message to check |

**Returns :**

- `boolean` : True if the error message indicates an unsupported custom depth error, false otherwise

---

### Fonction `EnableCustomDepthOnComponent(comp, bEnabled, stencilValue)`

Enables or disables custom depth rendering on a component, optionally setting a stencil value.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `comp` | `UActorComponent` | The component to modify |
| `bEnabled` | `boolean` | Whether to enable or disable custom depth rendering |
| `stencilValue` | `number` | The stencil value to use for custom depth rendering |

---

### Fonction `ProcessComponentHierarchy(comp, bEnabled, stencilValue, visited)`

Enables or disables custom depth rendering on a component and its attached children.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `comp` | `UActorComponent` | The component to modify |
| `bEnabled` | `boolean` | Whether to enable or disable custom depth rendering |
| `stencilValue` | `number` | The stencil value to use for custom depth rendering |

---

### Fonction `ApplyCustomDepthToActor(actor, bEnabled, stencilValue, visited)`

Applies or removes an outline effect on an entity by enabling or disabling custom depth rendering on its components and attached children.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `entity` | `AActor` | The entity to modify |
| `bEnabled` | `boolean` | Whether to enable or disable the outline effect |
| `stencilValue` | `number` | The stencil value to use for the outline effect |

---

### Fonction `SetEntityCustomDepth(entity, bEnabled, stencilValue)`

Adds or removes an outline effect on a whole entity by enabling or disabling custom depth rendering.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `entity` | `AActor` | The entity to modify |
| `bEnabled` | `boolean` | Whether to enable or disable the outline |
| `stencilValue` | `number` | The stencil value to use for the outline |

---

### Fonction `EntityOutline.AddEntityOutline(entity, stencilValue, key)`

Adds an outline effect to an entity.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `entity` | `AActor` | The entity to add an outline to |
| `stencilValue` | `number` | The stencil value to use for the outline |

---

### Fonction `EntityOutline.RemoveEntityOutline(entity)`

Removes the outline effect from an entity.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `entity` | `AActor` | The entity to remove the outline from |

---

### Fonction `EntityOutline.ToggleRaycastedEntityOutline(stencilValue)`

Toggles the outline effect on the entity currently under the player's crosshair.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `stencilValue` | `number` | The stencil value to use for the outline |

---

### Fonction `EntityOutline.GetOutlinedEntities()`

Returns the table of currently outlined entities.

**Returns :**

- `table` : A table containing the currently outlined entities, indexed by their unique keys

---

### Fonction `EntityOutline.ClearAllOutlines()`

Clears all outlines from entities and resets the outlined entities table.

---

### Fonction `EntityOutline.GC()`

Performs garbage collection on the outlined entities.

---

## Module `EntitySelector.lua`

### Fonction `EntitySelector.SelectEntity(entity)`

TODO : No purpose yet, will serve as a mass move/teleport function in the future when UI is implemented. TODO : Add comportment for when multiple selection is not authorised, i.e. deselect all other entities when a new one is selected. Selects an entity and adds it to the selection. If the entity is already selected, this function does nothing.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `entity` | `AActor` | The entity to select |

---

### Fonction `EntitySelector.DeselectEntity(entity)`

Deselects an entity from the selection. If the entity is not currently selected, this function does nothing.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `entity` | `AActor` | The entity to deselect |

---

### Fonction `EntitySelector.ToggleSelectionOfRaycastedEntity()`

Toggles the selection of an entity under the player's crosshair. If the entity is already selected, it will be deselected; if it is not selected, it will be added to the selection.

---

### Fonction `EntitySelector.AuthoriseMultipleSelection(doAuthorise)`

Authorises or deauthorises multiple entity selection. When multiple selection is authorised, the player can select multiple entities at once; when it is deauthorised, selecting a new entity will deselect any previously selected entities.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `doAuthorise` | `boolean` | If true, multiple selection is authorised; |

---

### Fonction `EntitySelector.IsMultipleSelectionAuthorised()`

Returns whether multiple entity selection is currently authorised.

**Returns :**

- `boolean` : True if multiple selection is authorised, false otherwise

---

### Fonction `EntitySelector.IsEntitySelected(entity)`

Checks if an entity is currently selected.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `entity` | `AActor` | The entity to check |

**Returns :**

- `boolean` : True if the entity is selected, false otherwise

---

### Fonction `EntitySelector.GetSelectedEntities()`

Returns the table of currently selected entities.

**Returns :**

- `table` : A table containing the currently selected entities, indexed by their unique keys

---

### Fonction `EntitySelector.ClearSelectedEntities()`

Clears all selected entities from the table.

---

### Fonction `EntitySelector.GC()`

Performs garbage collection on the selected entities.

---

## Module `GodMode.lua`

### Fonction `GodMode.ToggleGodMode(player, forceState)`

TODO : Need to implement other godmode features Toggles the god mode state for the player.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `player` | `AActor` | The player actor to toggle god mode for. If nil, the function will attempt to retrieve the player actor. |
| `forceState` | `boolean` | If provided, forces the god mode state to the specified value (true for enabled, false for disabled). If nil, the function will toggle the current state. |

---

## Module `NativeUI/Components/Button.lua`

### Fonction `GetClass()`

Retrieves the UClass for the button widget.

**Returns :**

- `UClass\|nil` : The button widget class.

---

### Fonction `EnsureHook()`

Ensures that the button click hook is installed to handle button click events.

---

### Fonction `ApplyButtonStyle(instance, stylePath)`

Applies a button style to the given widget instance.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `instance` | `UUserWidget` | Widget instance to style. |
| `stylePath` | `string\|UObject` | Style identifier, asset path, or style object. |

---

### Fonction `ButtonComponent.Create(initialText, onClick, stylePath)`

Creates a styled button component.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `initialText` | `string\|nil` | Initial button text. |
| `onClick` | `function\|nil` | Callback invoked with the button wrapper. |
| `stylePath` | `string\|nil` | Style identifier or asset path. |

**Returns :**

- `table\|nil` : Button wrapper, or nil when creation fails.

---

### Fonction `buttonObject:SetText(value)`

Updates the button text.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `value` | `any` | New button text. |

---

### Fonction `buttonObject:SetStyle(stylePath)`

Applies a button style.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `stylePath` | `string\|nil` | Style identifier or asset path. |

---

### Fonction `buttonObject:Refresh()`

Refreshes the native widget from the wrapper state.

---

### Fonction `ButtonComponent.GC()`

Removes invalid widgets from the button callback registry.

---

## Module `NativeUI/Components/Column.lua`

### Fonction `GetClass()`

Resolves and caches the native vertical box class.

**Returns :**

- `UClass\|nil` : The vertical box class.

---

### Fonction `Column.Create(parentWidget)`

Creates a vertical column container.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `parentWidget` | `UWidget\|table\|nil` | Optional parent used as the memory owner. |

**Returns :**

- `table\|nil` : Column wrapper, or nil when creation fails.

---

### Fonction `Column:Add(widgetItem, fillRatio, padding)`

Adds a widget to the column.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `widgetItem` | `table\|UWidget` | Component wrapper or widget to add. |
| `fillRatio` | `number\|nil` | Fill ratio; zero or nil uses automatic sizing. |
| `padding` | `table\|nil` | Optional Slate padding. |

**Returns :**

- `FVerticalBoxSlot\|nil` : Created slot, or nil when adding fails.

---

### Fonction `Column:Refresh()`

Refreshes all child components in the column.

---

## Module `NativeUI/Components/Row.lua`

### Fonction `GetClass()`

Resolves and caches the native horizontal box class.

**Returns :**

- `UClass\|nil` : The horizontal box class.

---

### Fonction `GetSizeBoxClass()`

Resolves and caches the native size box class.

**Returns :**

- `UClass\|nil` : The size box class.

---

### Fonction `WrapInSizeBox(rawWidget, width, height, outer)`

Wraps a widget in a size box when width or height constraints are provided.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `rawWidget` | `UWidget` | Widget to wrap. |
| `width` | `number\|nil` | Optional width constraint. |
| `height` | `number\|nil` | Optional height constraint. |
| `outer` | `UObject\|nil` | Memory owner for the size box. |

**Returns :**

- `UWidget` : Original or wrapped widget.

---

### Fonction `Row.Create(parentWidget)`

Creates a horizontal row container.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `parentWidget` | `UWidget\|table\|nil` | Optional parent used as the memory owner. |

**Returns :**

- `table\|nil` : Row wrapper, or nil when creation fails.

---

### Fonction `Row:Add(widgetItem, fillRatio, padding, verticalAlignment, constraints)`

Adds a widget to the row.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `widgetItem` | `table\|UWidget` | Component wrapper or widget to add. |
| `fillRatio` | `number\|nil` | Fill ratio; zero or nil uses automatic sizing. |
| `padding` | `table\|nil` | Optional Slate padding. |
| `verticalAlignment` | `number\|nil` | Vertical alignment enum. |
| `constraints` | `table\|nil` | Optional width and height constraints. |

**Returns :**

- `FHorizontalBoxSlot\|nil` : Created slot, or nil when adding fails.

---

### Fonction `Row:Refresh()`

Refreshes all child components in the row.

---

## Module `NativeUI/Components/Slider.lua`

### Fonction `GetClass()`

Retrieves the UClass for the slider widget.

**Returns :**

- `UClass\|nil` : The slider widget class.

---

### Fonction `EnsureWatcher()`

Starts the asynchronous value watcher loop if not already running.

---

### Fonction `SliderComponent.Create(min_val, max_val, default_val, step_size, on_change)`

Creates a slider component.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `min_val` | `number\|nil` | Minimum value; defaults to 0.0. |
| `max_val` | `number\|nil` | Maximum value; defaults to 1.0. |
| `default_val` | `number\|nil` | Initial value; defaults to min_val. |
| `step_size` | `number\|nil` | Step size for value changes; defaults to 0.05. |
| `on_change` | `function\|nil` | Callback invoked with the new value and wrapper. |

**Returns :**

- `table\|nil` : Slider wrapper, or nil when creation fails.

---

### Fonction `sliderObject:SetValue(value)`

Sets the slider's value, clamping it within the defined range.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `value` | `number` | New value to set. |

---

### Fonction `sliderObject:GetValue()`

Returns the current value of the slider.

**Returns :**

- `number` : Current slider value.

---

### Fonction `sliderObject:Refresh()`

Refreshes the native widget from the wrapper state.

---

### Fonction `SliderComponent.GC()`

Removes invalid widgets from the slider callback registry.

---

## Module `NativeUI/Components/Spacer.lua`

### Fonction `GetClass()`

Resolves and caches the native UMG spacer class.

**Returns :**

- `UClass\|nil` : The spacer class.

---

### Fonction `Spacer.Create(outer)`

Creates a native UMG spacer widget.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `outer` | `UWidget\|nil` | Memory owner for the new widget. |

**Returns :**

- `table\|nil` : Spacer wrapper, or nil when creation fails.

---

## Module `NativeUI/Components/Switch.lua`

### Fonction `GetClass()`

Retrieves the UClass for the switch widget.

**Returns :**

- `UClass\|nil` : The switch widget class.

---

### Fonction `EnsureHook()`

Ensures that the switch click hook is installed to handle switch toggle events.

---

### Fonction `ApplySwitchStyle(instance, stylePath)`

Applies a switch style to the given widget instance.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `instance` | `UUserWidget` | Widget instance to style. |
| `stylePath` | `string\|UObject` | Style identifier, asset path, or style object. |

---

### Fonction `SwitchComponent.Create(initialState, onToggle, stylePath)`

Creates a switch component.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `initialState` | `boolean\|nil` | Initial checked state. |
| `onToggle` | `function\|nil` | Callback invoked with the new state and wrapper. |
| `stylePath` | `string\|nil` | Style identifier or asset path. |

**Returns :**

- `table\|nil` : Switch wrapper, or nil when creation fails.

---

### Fonction `switchObject:SetState(state)`

Sets the checked state.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `state` | `boolean` | New checked state. |

---

### Fonction `switchObject:SetStyle(stylePath)`

Applies a switch style.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `stylePath` | `string\|nil` | Style identifier or asset path. |

---

### Fonction `switchObject:Refresh()`

Refreshes the native widget from the wrapper state.

---

### Fonction `switchObject:Toggle()`

Toggles the checked state and invokes the callback.

---

### Fonction `SwitchComponent.GC()`

Removes invalid widgets from the switch callback registry.

---

## Module `NativeUI/Components/Text/Text.lua`

### Fonction `GetClass()`

Retrieves the UClass for the text widget.

**Returns :**

- `UClass\|nil` : The text widget class.

---

### Fonction `TextComponent.Create(initialText, stylePath, showLine)`

Creates a text component with an optional decorative line.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `initialText` | `string\|nil` | Initial text. |
| `stylePath` | `string\|nil` | Style identifier or asset path. |
| `showLine` | `boolean\|nil` | Whether to show the widget's decorative line. |

**Returns :**

- `table\|nil` : Text wrapper, or nil when creation fails.

---

### Fonction `textObject:SetText(value)`

Updates the text value.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `value` | `any` | New text value. |

---

### Fonction `textObject:SetStyle(stylePath)`

Applies a text style.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `stylePath` | `string\|nil` | Style identifier or asset path. |

---

### Fonction `textObject:Refresh()`

Refreshes the native widget from the wrapper state.

---

## Module `NativeUI/Components/Text/TextUtils.lua`

### Fonction `ResolveTextBlock(instance)`

Finds the first valid text block exposed by a widget.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `instance` | `UUserWidget` | Widget containing a text block. |

**Returns :**

- `UTextBlock\|nil` : Text block, or nil when unavailable.

---

### Fonction `TextUtils.ApplyStyle(instance, stylePath)`

Applies a CommonUI text style to the first available text block on a widget.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `instance` | `UUserWidget` | Widget containing a text block. |
| `stylePath` | `string\|UObject` | Style identifier, asset path, or style object. |

---

### Fonction `TextUtils.SetText(instance, text)`

Applies text to the first available text property on a widget.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `instance` | `UUserWidget` | Widget containing a text block. |
| `text` | `FText` | Unreal text value. |

---

## Module `NativeUI/Components/Text/Title.lua`

### Fonction `GetClass()`

Retrieves the UClass for the title widget.

**Returns :**

- `UClass\|nil` : The title widget class.

---

### Fonction `TitleComponent.Create(initialText, stylePath)`

Creates a title component.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `initialText` | `string\|nil` | Initial title text. |
| `stylePath` | `string\|nil` | Style identifier or asset path. |

**Returns :**

- `table\|nil` : Title wrapper, or nil when creation fails.

---

### Fonction `titleObject:SetText(value)`

Updates the title text.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `value` | `any` | New title text. |

---

### Fonction `titleObject:SetStyle(stylePath)`

Applies a title text style.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `stylePath` | `string\|nil` | Style identifier or asset path. |

---

### Fonction `titleObject:Refresh()`

Refreshes the native widget from the wrapper state.

---

## Module `NativeUI/Components/TextInput.lua`

### Fonction `GetClass()`

Retrieves the native UClass for EditableTextBox.

**Returns :**

- `UClass\|nil` : 

---

### Fonction `EnsureWatcher()`

Starts the asynchronous value watcher loop if not already running.

---

### Fonction `UpdateStyleBrush(widget, brushName, color)`

Updates the background color of a specific brush in the widget's style.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `widget` | `UWidget` | The native UMG widget. |
| `brushName` | `string` | The name of the brush property to update (e.g., "BackgroundImageNormal"). |
| `color` | `table` | A table representing the color with fields R, G, B, A (values between 0.0 and 1.0). |

---

### Fonction `TextInputComponent.Create(placeholder, initialText, onCommit, onChange, isPassword)`

Creates a text input box component.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `placeholder` | `string\|nil` | Hint text when empty. |
| `initialText` | `string\|nil` | Default text inside the box. |
| `onCommit` | `function\|nil` | Callback fn(text, commitMethod, inputObject) on Enter or focus lost. |
| `onChange` | `function\|nil` | Callback fn(text, inputObject) on text change. |
| `isPassword` | `boolean\|nil` | Whether the input should be treated as a password. |

**Returns :**

- `table\|nil` : TextInput wrapper object.

---

### Fonction `inputObject:SetText(newText)`

Sets the text inside the input box and updates the internal state.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `newText` | `string` | The new text to set in the input box. |

---

### Fonction `inputObject:GetText()`

Retrieves the current text from the input box, updating the internal state if necessary.

**Returns :**

- `string` : The current text in the input box.

---

### Fonction `inputObject:Clear()`

Clears the text input box.

---

### Fonction `inputObject:SetHintText(newHint)`

Sets the hint text for the input box.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `newHint` | `string` | The new hint text to display when the input is empty. |

---

### Fonction `inputObject:Refresh()`

Refreshes the native widget to reflect the current text and hint text.

---

### Fonction `inputObject:SetBackgroundColorNormal(color)`

Sets the background color of the input box when not hovered or focused.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `color` | `table` | RGB(A) table like { R = 1.0, G = 1.0, B = 1.0, A = 1.0 } |

---

### Fonction `inputObject:SetBackgroundColorHovered(color)`

Sets the background color of the input box when hovered.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `color` | `table` | RGB(A) table like { R = 1.0, G = 1.0, B = 1.0, A = 1.0 } |

---

### Fonction `inputObject:SetBackgroundColorFocused(color)`

Sets the background color of the input box when it is focused.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `color` | `table` | RGB(A) table like { R = 1.0, G = 1.0, B = 1.0, A = 1.0 } |

---

### Fonction `inputObject:SetTextColor(color)`

Sets the text color inside the input box.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `color` | `table` | RGB(A) table like { R = 1.0, G = 1.0, B = 1.0, A = 1.0 } |

---

### Fonction `inputObject:SetFont(fontAssetPathOrObject, size)`

Changes the font asset used by the input box.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `fontAssetPathOrObject` | `string\|UObject` | Path to the font asset or the UFont object itself. |
| `size` | `number\|nil` | Optional size to apply alongside the font. |

---

### Fonction `inputObject:SetFontSize(size)`

Sets the text font size.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `size` | `number` | Size in points (e.g. 14.0, 16.0) |

---

### Fonction `inputObject:SetErrorState(isError)`

Sets the input box to an error state, changing its background colors to indicate an error.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `isError` | `boolean` | Whether to enable or disable the error state. |

---

### Fonction `inputObject:SetReadOnly(isReadOnly)`

Sets whether the input box is read-only, preventing user edits.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `isReadOnly` | `boolean` | Whether to make the input box read-only. |

---

### Fonction `inputObject:SetIsPassword(isPassword)`

Toggles password masking mode.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `isPassword` | `boolean` |  |

---

### Fonction `inputObject:SetKeyboardFocus()`

Set keyboard focus to this input box, allowing the user to type into it.

---

### Fonction `inputObject:HasFocus()`

Checks if this input box currently has keyboard focus.

**Returns :**

- `boolean` : True if the input box has focus, false otherwise.

---

### Fonction `TextInputComponent.GC()`

Removes invalid widgets from the callback registry.

---

## Module `NativeUI/Core.lua`

### Fonction `Core.Init()`

Initializes the cached Unreal UI libraries used by NativeUI.

**Returns :**

- `boolean` : True when both required libraries are available.

---

### Fonction `Core.RegisterButtonClickHandler(handlerKey, handler)`

Registers a named callback for CommonUI button clicks.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `handlerKey` | `string` | Stable callback identifier used across reloads. |
| `handler` | `function` | Callback receiving the clicked widget. |

**Returns :**

- `boolean` : True when the handler was registered.

---

### Fonction `Core.RegisterFocusableInput(widget)`

Registers an input widget that consumes keyboard focus.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `widget` | `UWidget` | The native Slate/UMG widget. |

---

### Fonction `Core.UnregisterFocusableInput(widget)`

Unregisters an input widget when destroyed.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `widget` | `UWidget` |  |

---

### Fonction `Core.IsAnyInputFocused()`

Checks if any registered text/editable input currently has keyboard focus.

**Returns :**

- `boolean` : 

---

### Fonction `Core.CommitFocusedInput()`

Commits the currently focused text input, if any.

---

## Module `NativeUI/Style/StyleExtractor.lua`

### Fonction `ResolveStyleMetadata(fullClassPath)`

Analyzes an asset path to extract its style category and clean key.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `fullClassPath` | `string` | The full Unreal asset path |

**Returns :**

- `string\|nil` : The style category (e.g., "Text", "Button") and the clean key (e.g., "Style_Text_Header1")

---

### Fonction `StyleExtractor.ScanAll(dumpFile)`

Scans the entire GUObjectArray to extract all style assets and cache them.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `dumpFile` | `string\|nil` | Optional file to dump the global documentation. |

**Returns :**

- `table` : Cached styles organized by category.

---

### Fonction `StyleExtractor.GetCachedStyleType(styleType)`

Gets cached styles for a category, scanning on demand when necessary.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `styleType` | `string` | The style category (e.g., "Text", "Button"). |

**Returns :**

- `table` : Cached styles indexed by clean style key.

---

### Fonction `StyleExtractor.GetAllCachedStyles()`

Returns all cached styles organized by category.

**Returns :**

- `table` : A table of cached styles organized by category.

---

### Fonction `StyleExtractor.GetAvailableCachedStylesTypes()`

Returns all cached style categories.

**Returns :**

- `table` : A table containing the available style categories.

---

## Module `NativeUI/Style/StyleUtils.lua`

### Fonction `StyleHelper.ResolveStyle(category, stylePath)`

Resolves a style identifier or asset path to a style UObject.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `category` | `string` | Style category, such as Button or Text. |
| `stylePath` | `string\|UObject` | Style identifier, asset path, or style object. |

**Returns :**

- `UObject\|nil` : Resolved style object, or nil when unavailable.

---

## Module `NativeUI/Window.lua`

### Fonction `GetBackgroundClass()`

Resolves and caches the background widget class.

**Returns :**

- `UClass\|nil` : The background widget class.

---

### Fonction `GetSizeBoxClass()`

Resolves and caches the native size box class.

**Returns :**

- `UClass\|nil` : The size box class.

---

### Fonction `GetBlurWidget(instance)`

Finds the background blur widget in a root widget.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `instance` | `UUserWidget\|nil` | Root widget to inspect. |

**Returns :**

- `UWidget\|nil` : Background blur widget, or nil when unavailable.

---

### Fonction `WrapInSizeBox(rawWidget, width, height, outer)`

Wraps a widget in a UMG size box when constraints are provided.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `rawWidget` | `UWidget` | Widget to wrap. |
| `width` | `number\|nil` | Optional width constraint. |
| `height` | `number\|nil` | Optional height constraint. |
| `outer` | `UObject\|nil` | Memory owner for the size box. |

**Returns :**

- `UWidget` : Original or wrapped widget.

---

### Fonction `Window.New(config)`

Creates a NativeUI window backed by the game's background widget.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `config` | `table\|nil` | Window options: x, y, w, h, and zOrder. |

**Returns :**

- `table\|nil` : A window object, or nil when the widget cannot be created.

---

### Fonction `Window:AddHeaderWidget(component, padding, verticalAlignment)`

Adds a component to the window header.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `component` | `table\|UWidget` | Component wrapper or widget to add. |
| `padding` | `table\|nil` | Optional Slate padding. |
| `verticalAlignment` | `number\|nil` | Vertical alignment enum. |

---

### Fonction `Window:AddBodyWidget(widgetItem, constraints)`

Adds a component to the window body.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `widgetItem` | `table\|UWidget` | Component wrapper or widget to add. |
| `constraints` | `table\|nil` | Optional padding, width, height, and fill settings. |

---

### Fonction `Window:SetBlurStrength(strength)`

Sets the background blur strength.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `strength` | `number` | Blur strength; zero disables the blur. |

---

### Fonction `Window:DisableBlur()`

Disables the background blur.

---

### Fonction `Window:Show()`

Shows the window and enables game-and-UI input.

---

### Fonction `Window:Hide()`

Hides the window and restores game-only input.

---

### Fonction `Window:Toggle()`

Toggles the window visibility.

---

## Module `NoClip.lua`

### Fonction `ScheduleActivationRetry()`

TODO : Player Pawn not really pinnd on the camera, a bit under and dont know why TODO : Still feels laggy / jittery. Core functionality is working, but may need to be optimized further. Hint : maybe get rid of the teleport function or lighten it. Interpolation ? Retries noclip activation while the game is replacing its player controller.

---

### Fonction `CaptureAndDisablePawn(pawn)`

Saves the pawn state and disables damage, collision, and gravity for noclip.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `pawn` | `APawn` | Pawn whose state should be captured and disabled |

**Returns :**

- `table\|nil` : Saved pawn state, or nil when the pawn is invalid

---

### Fonction `RestorePawnState(state)`

Restores the pawn and attached actors to their pre-noclip state.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `state` | `table\|nil` | State returned by CaptureAndDisablePawn |

---

### Fonction `NoClip.ToggleNoClip()`

Toggles debug-camera noclip for the local player's current pawn.

---

## Module `PlayerCheat.lua`

### Fonction `PlayerCheat.TogglePlayerCheatMode()`

Toggles the player cheat mode state, granting or removing special abilities.

---

## Module `Spawner.lua`

### Fonction `IsStaticMeshAsset(asset, assetPath)`

Detect meshes by path or reflected type.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `asset` | `UObject` | The asset to inspect |
| `assetPath` | `string` | The full Unreal asset path |

**Returns :**

- `boolean` : True when the asset is a StaticMesh

---

### Fonction `LoadAssetWithRetries(assetPath, verbose)`

Resolve a typed mesh reference before passing it to SetStaticMesh. Asset loading can be asynchronous, so retry a few times.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `assetPath` | `string` | The full Unreal asset path |
| `verbose` | `boolean` | Whether to print debug messages |

**Returns :**

- `UStaticMesh\|nil` : The resolved mesh reference, or nil if not found

---

### Fonction `Spawner.SpawnActor(ActorClassPath, distInFront, verbose)`

Spawns an actor of the specified class in front of the player.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `ActorClassPath` | `string` | The full Unreal asset path of the actor class |
| `distInFront` | `number` | The distance in front of the player to spawn the actor |
| `verbose` | `boolean` | Whether to print debug messages |

**Returns :**

- `AActor\|nil` : The spawned actor, or nil if spawning failed

---

### Fonction `Spawner.DeleteActor(Actor, verbose)`

Deletes an actor and cleans up its tracking.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `Actor` | `AActor` | The actor to delete |
| `verbose` | `boolean` | Whether to print debug messages |

---

### Fonction `Spawner.GetAllTrackedActors()`

Retrieves all currently tracked actors from the entity tracker.

**Returns :**

- `table` : A list of all valid tracked actors

---

### Fonction `Spawner.GC()`

Performs garbage collection on the entity tracker, removing invalid actors.

**Returns :**

- `boolean` : Always returns false to indicate the GC process is complete

---

## Module `Teleport.lua`

### Fonction `Teleport.TeleportPawn(posTable, isOffset, rotTable, verbose, targetPawn)`

Teleports a pawn to an absolute or relative position and optionally rotates it. Position and rotation accept either named components or numeric components.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `posTable` | `table` | Target position: {X, Y, Z} or {1, 2, 3} |
| `isOffset` | `boolean\|nil` | Add the position to the pawn's current location |
| `rotTable` | `table\|nil` | Target rotation: {Pitch, Yaw, Roll} or numeric components |
| `verbose` | `boolean\|nil` | Print the position before and after teleportation |
| `targetPawn` | `APawn\|nil` | Pawn to move; resolves the local player's pawn when omitted |

**Returns :**

- `boolean` : True when the location and optional rotation were applied successfully

---

## Module `system/GcScheduler.lua`

### Fonction `GCScheduler.RegisterGC(gcFunction, interval, stagger)`

Register a garbage collection function to be executed periodically.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `gcFunction` | `function` | The function to be executed for garbage collection. |
| `interval` | `number` | The time interval in seconds between executions of the function. |
| `stagger` | `boolean` | If true, the initial execution of the function will be staggered by a random offset within the interval. |

---

### Fonction `GCScheduler.UnregisterGC(gcFunction)`

Unregister a previously registered garbage collection function.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `gcFunction` | `function` | The function to be unregistered. |

---

### Fonction `GCScheduler.Update(deltaTime)`

Update function to be called every frame to check if any registered GC functions need to be executed.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `deltaTime` | `number` | The time elapsed since the last frame, in seconds. |

---

## Module `system/ShortNamingUtils.lua`

### Fonction `CacheShortName(shortName, assetPath)`

Caches a short name and its corresponding asset path in the short naming map and saves it to the config file.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `shortName` | `string` | The short name to cache. |
| `assetPath` | `string` | The full asset path corresponding to the short name. |

**Returns :**

- `string` : The asset path that was cached.

---

### Fonction `FindBlueprintPath(shortName)`

Attempts to find the full asset path for a given short name by searching through probable blueprint paths.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `shortName` | `string` | The short name to search for. |

**Returns :**

- `string or nil` : The full asset path if found, or nil if not found.

---

### Fonction `ShortNaming.HandleShortNaming(ActorShortName)`

Handles short naming for actor class paths. If the provided name is already a full path, it returns it as is. Otherwise, it attempts to resolve the short name to a full path using the short naming map or by searching probable blueprint paths.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `ActorShortName` | `string` | The short name or full path of the actor class. |

**Returns :**

- `string or nil` : The resolved full path of the actor class, or nil if not found.

---

### Fonction `ShortNaming.PopulateShortNamesFromFile(filePath)`

Populates the short naming map from a configuration file. If the file contains a "ShortNaming" section, it reads each entry and adds it to the short naming map.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `filePath` | `string` | The path to the configuration file. |

---

### Fonction `ShortNaming.ConstructName(path, name)`

Constructs a full asset path from a base path and a short name. This is used to generate the expected full path for a given short name.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `path` | `string` | The base path where the asset is located. |
| `name` | `string` | The short name of the asset. |

**Returns :**

- `string` : The constructed full asset path.

---

## Module `utils/Entity.lua`

### Fonction `Entity.IsVehiclePawn(playerControllerOrCharacter)`

Checks if a given player controller or character is currently in a vehicle.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `playerControllerOrCharacter` | `UPlayerController\|ACharacter` | The player controller or character to check |

**Returns :**

- `boolean` : True if the player is in a vehicle, false otherwise

---

### Fonction `Entity.GetActorLocation(actor)`

Retrieves an actor's world location using the available Unreal accessor.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `actor` | `AActor` | The actor whose location should be read |

**Returns :**

- `FVector\|nil` : The normalized world location, or nil when unavailable

---

### Fonction `Entity.GetObjectName(object)`

Retrieves an object's name using the most specific available Unreal accessor.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `object` | `UObject` | The object to inspect |

**Returns :**

- `string\|nil` : The object name, or nil when unavailable

---

### Fonction `Entity.HasObjectName(object, expectedName)`

Checks whether an object's name matches an expected name, allowing Unreal numeric suffixes.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `object` | `UObject` | The object to inspect |
| `expectedName` | `string` | The expected object name |

**Returns :**

- `boolean` : True when the object name matches

---

### Fonction `Entity.ResolveStaticMesh(assetPath, fallbackAsset)`

Resolves a StaticMesh reference from an Unreal asset path.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `assetPath` | `string` | The full Unreal asset path |
| `fallbackAsset` | `UObject` | The asset returned when typed resolution fails |

**Returns :**

- `UStaticMesh\|UObject\|nil` : The resolved mesh reference

---

### Fonction `Entity.GetEntityKey(entity)`

Generates a unique key for an entity based on its address or full name.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `entity` | `AActor\|UObject` | The entity to generate a key for |

**Returns :**

- `string\|nil` : A unique string key for the entity, or nil if the entity is invalid

---

### Fonction `Entity.GetTopLevelEntity(entity)`

Retrieves the top-level entity for a given entity, considering ownership and attachment.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `entity` | `AActor\|UObject` | The entity to inspect |

**Returns :**

- `AActor\|UObject` : The top-level entity, or the original entity if no higher level is found

---

### Fonction `Entity.DisableEntityCollision(entity)`

Disables collision for a given entity, attempting multiple methods to ensure collision is turned off.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `entity` | `AActor\|UObject` | The entity to disable collision for |

**Returns :**

- `boolean` : True if collision was successfully disabled, false otherwise

---

## Module `utils/Math.lua`

### Fonction `Math.GetPositionInFront(Position, Rotation, distance)`

Teleports the player to a specified position and rotation.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `Position` | `table` | A table with X, Y, Z fields representing the current position |
| `Rotation` | `table` | A table with Pitch, Yaw, Roll fields representing the target rotation |
| `distance` | `number` | Distance to offset in the direction vector |

**Returns :**

- `number, number, number` : The new X, Y, Z coordinates after applying the offset

---

### Fonction `Math.GetForwardVector(Rotation)`

Computes the forward vector from pitch and yaw angles.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `Rotation` | `table` | A table with Pitch, Yaw, Roll fields |

**Returns :**

- `table` : A table representing the forward vector with X, Y, Z fields

---

### Fonction `Math.CheckLocationEquality(locA, locB, tolerance)`

Checks if two locations are approximately equal within a given tolerance.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `locA` | `table` | First location with X, Y, Z fields |
| `locB` | `table` | Second location with X, Y, Z fields |
| `tolerance` | `number` | The maximum allowed difference for each coordinate |

**Returns :**

- `boolean` : True if locations are approximately equal, false otherwise

---

## Module `utils/Path.lua`

### Fonction `Path.SanitizePath(path)`

Corrects the path separators in a given path string.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `path` | `string` | The path with \ |

**Returns :**

- `string` : The cleaned path with /

---

### Fonction `Path.GetModFolder(scriptFullPath)`

Retrieves the mod folder path from a script's full path.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `scriptFullPath` | `string` | The full path of the script |

**Returns :**

- `string` : The mod folder path

---

### Fonction `Path.RequireUE4SSDump(filePath)`

Dynamically requires a UE4SS dump file, patching it to use global variables, because it overlaps the 200 local limit.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `filePath` | `string` | The file path to the UE4SS dump Lua file |

**Returns :**

- `table` : The environment table containing the dumped variables, or nil and an error

---

## Module `utils/Player.lua`

### Fonction `IsDebugCameraController(controller)`

Checks whether a controller belongs to the debug camera system.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `controller` | `UPlayerController` | The controller to inspect |

**Returns :**

- `boolean` : True when the controller is a debug camera controller

---

### Fonction `Player.ResetDebugCameraControllerCache()`

Resets the cached Debug Camera Controller, forcing a re-evaluation on the next retrieval.

---

### Fonction `Player.GetDebugCameraController()`

Gets the Debug Camera Controller for the local player, caching it for future calls.

**Returns :**

- `UPlayerController` : The Debug Camera Controller object

---

### Fonction `Player.EnableCheatManager(playerController)`

Enables the cheat manager for a given player controller, constructing it if necessary.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `playerController` | `UPlayerController` | The player controller to enable the cheat manager for |

**Returns :**

- `boolean` : True if the cheat manager is enabled or already present, false otherwise

---

### Fonction `Player.GetPlayerController()`

Retrieves the local player controller, ensuring it is valid and not a debug camera controller.

**Returns :**

- `UPlayerController\|nil` : The local player controller, or nil if not found

---

### Fonction `Player.GetPlayer()`

Gets the local player pawn, ensuring it is valid.

**Returns :**

- `APawn\|nil` : The local player pawn, or nil if not found

---

## Module `utils/Types.lua`

### Fonction `PackValues(...)`

Packs variadic values while preserving trailing nil values.

**Returns :**

- `table` : Packed values and their count.

---

### Fonction `Types.IsValidObject(object)`

Checks if an object is valid (not nil and not destroyed).

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `object` | `UObject` | The object to check |

**Returns :**

- `boolean` : True if the object is valid, false otherwise

---

### Fonction `Types.UnwrapValue(value)`

Unwraps a value returned through a UE4SS remote parameter.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `value` | `any` | A direct value or a UE4SS remote parameter |

**Returns :**

- `any` : The unwrapped value, or the original value when unchanged

---

### Fonction `Types.ReadNumber(value)`

Reads a numeric value returned directly or wrapped by UE4SS.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `value` | `any` | A number or UE4SS numeric parameter |

**Returns :**

- `number\|nil` : The numeric value, or nil when unavailable

---

### Fonction `Types.ReadVectorComponent(vector, component)`

Reads one component from a vector returned by UE4SS.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `vector` | `FVector\|UScriptStruct` | The vector to inspect |
| `component` | `string` | The component name, such as X, Y, or Z |

**Returns :**

- `number\|nil` : The component value, or nil when unavailable

---

### Fonction `Types.ReadVector(vector)`

Reads and normalizes a three-dimensional vector.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `vector` | `FVector\|UScriptStruct\|table` | The vector to read |

**Returns :**

- `table\|nil` : A table with numeric X, Y, and Z fields, or nil when invalid

---

### Fonction `Types.NormalizeVector(value, namedKeys)`

Normalizes a vector represented as a table with named keys.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `value` | `table` | The vector to normalize |
| `namedKeys` | `table` | A table containing the names of the keys to use for the vector components |

**Returns :**

- `table\|nil` : A normalized vector table with the same named keys, or nil if the input is invalid

---

### Fonction `Types.ToFText(value)`

Converts a Lua value to an Unreal FText.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `value` | `any` | Text content to convert. |

**Returns :**

- `FText\|nil` : The converted text, or nil when the text library is unavailable.

---

### Fonction `Types.GetFTextString(ftext)`

Retrieves a string from an Unreal FText.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `ftext` | `FText` | The FText to convert. |

**Returns :**

- `string\|nil` : The converted string, or nil when the text library is unavailable.

---

### Fonction `Types.TryCall(operationName, callback, silently)`

Executes a protected operation and reports failures with a consistent prefix.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `operationName` | `string` | Operation description used in the error message. |
| `callback` | `function` | Operation to execute. |
| `silently` | `boolean` | Whether to suppress error messages. |

**Returns :**

- `boolean, any` : Success state and callback results or error message.

---

### Fonction `Types.ConstructObject(objectClass, outer)`

Constructs a UE4SS object, retrying with the extended signature when needed.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `objectClass` | `UClass` | Class to instantiate. |
| `outer` | `UObject` | Memory owner for the new object. |

**Returns :**

- `UObject\|nil` : Constructed object, or nil when construction fails.

---

## Module `utils/World.lua`

### Fonction `World.FindSurfaceBelow(Actor, Position)`

Finds the first blocking surface below a world position.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `Actor` | `AActor` | The actor ignored by the trace |
| `Position` | `FVector` | The center of the vertical trace |

**Returns :**

- `FVector\|nil` : The impact point, or nil when no surface is hit

---

### Fonction `World.PlaceActorOnSurface(Actor, MeshComponent, MeshAsset, SurfacePoint)`

TODO : Rework the following function since it seems to be inconsistent on the ground placement Moves an actor so the bottom of its bounds touches a surface point.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `Actor` | `AActor` | The actor to move |
| `MeshComponent` | `UStaticMeshComponent` | The mesh component used for bounds |
| `MeshAsset` | `UStaticMesh` | The mesh asset used as a bounds fallback |
| `SurfacePoint` | `FVector\|nil` | The target surface point |

**Returns :**

- `nil` : This function does not return a value

---

### Fonction `getCameraData(camera)`

Reads the location and rotation from a camera manager.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `camera` | `APlayerCameraManager` | The camera manager to inspect |

**Returns :**

- `FVector\|nil, FRotator\|nil` : Camera location and rotation

---

### Fonction `getHitObject(hitResult)`

Extracts the object represented by a line trace hit result.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `hitResult` | `FHitResult` | The Unreal hit result |

**Returns :**

- `UObject\|nil` : The hit object, actor, or component

---

### Fonction `World.PerformRaycast(Position, Pawn, Camera, Direction, Rotation, Length, TraceChannel, TraceComplex, ActorsToIgnore, IgnoreSelf, DrawDebug, DrawTime, TraceColor, TraceHitColor)`

Performs a configurable line trace.

**Parameters :**

| Name | Type | Description |
| :--- | :--- | :--- |
| `Position` | `FVector\|nil` | Ray origin; camera or pawn location is used when nil |
| `Pawn` | `APawn\|nil` | Pawn used as the default self actor and fallback origin |
| `Camera` | `APlayerCameraManager\|nil` | Camera used as the default origin and direction |
| `Direction` | `FVector\|nil` | Normalized ray direction; camera or pawn rotation is used when nil |
| `Rotation` | `FRotator\|nil` | Rotation used to derive the ray direction |
| `Length` | `number\|nil` | Ray length, default 50000 |
| `TraceChannel` | `number\|nil` | 1 WorldStatic, 2 WorldDynamic, 3 Pawn, 4 Visibility, 5 Camera |
| `TraceComplex` | `boolean\|nil` | Whether to use complex collision, default true |
| `ActorsToIgnore` | `table\|nil` | Actors excluded from the trace |
| `IgnoreSelf` | `boolean\|nil` | Whether to ignore Pawn, default true |
| `DrawDebug` | `boolean\|number\|nil` | Debug mode: false/0 none, true/1 one frame, 2 duration, 3 persistent |
| `DrawTime` | `number\|nil` | Duration used by debug drawing |
| `TraceColor` | `FLinearColor\|table\|nil` | Debug color before a hit |
| `TraceHitColor` | `FLinearColor\|table\|nil` | Debug color after a hit |

**Returns :**

- `UObject\|nil, FHitResult\|nil, boolean` : Hit object, result, and success

---
