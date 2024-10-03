pub const Byte = u8;
pub const Ptr = usize;
pub const Hash = u32;
pub const Flags = u32;
pub const Rune = u32;

pub const BufferMarker = extern struct {
    active: bool,
    offset: usize,
};

pub const AllocFn = ?*const fn (Handle, ?*anyopaque, usize) callconv(.C) ?*anyopaque;
pub const FreeFn = ?*const fn (Handle, ?*anyopaque) callconv(.C) void;

pub const Allocator = extern struct {
    userdata: Handle,
    alloc: AllocFn,
    free: FreeFn,
};

pub const AllocationType = enum(c_uint) {
    fixed = 0,
    dynamic = 1,
};

pub const Memory = extern struct {
    ptr: ?*anyopaque,
    size: usize,
};

pub const Rect = extern struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,

    pub fn new(x: f32, y: f32, w: f32, h: f32) Rect {
        return .{ .x = x, .y = y, .w = w, .h = h };
    }
};

pub const DrawCommand = extern struct {
    elem_count: c_uint,
    clip_rect: Rect,
    texture: Handle,
};

pub const AntiAliasing = enum(c_uint) {
    off = 0,
    on = 1,
};

pub const Vec2 = extern struct {
    x: f32,
    y: f32,

    pub fn new(x: f32, y: f32) Vec2 {
        return .{ .x = x, .y = y };
    }
};

pub const DrawNullTexture = extern struct {
    texture: Handle,
    uv: Vec2,
};

pub const DrawVertexLayoutAttribute = enum(c_uint) {
    position = 0,
    color = 1,
    texcoord = 2,
    undef = 3,
};

pub const DrawVertexLayoutFormat = enum(c_uint) {
    schar = 0,
    sshort = 1,
    sint = 2,
    uchar = 3,
    ushort = 4,
    uint = 5,
    float = 6,
    double = 7,
    r8g8b8 = 8,
    r16g15b16 = 9,
    r32g32b32 = 10,
    r8g8b8a8 = 11,
    b8g8r8a8 = 12,
    r16g15b16a16 = 13,
    r32g32b32a32 = 14,
    r32g32b32a32float = 15,
    r32g32b32a32double = 16,
    rgb32 = 17,
    rgba32 = 18,
    undef = 19,
};

pub const DrawVertexLayoutElement = extern struct {
    attribute: DrawVertexLayoutAttribute,
    format: DrawVertexLayoutFormat,
    offset: usize,
};

pub const draw_vertex_layout_end = DrawVertexLayoutElement{
    .attribute = .undef,
    .format = .undef,
    .offset = 0,
};

pub const ConvertConfig = extern struct {
    global_alpha: f32,
    line_AA: AntiAliasing,
    shape_AA: AntiAliasing,
    circle_segment_count: c_uint,
    arc_segment_count: c_uint,
    curve_segment_count: c_uint,
    tex_null: DrawNullTexture,
    vertex_layout: [*c]const DrawVertexLayoutElement,
    vertex_size: usize,
    vertex_alignment: usize,
};

pub const StyleItemType = enum(c_uint) {
    color = 0,
    image = 1,
    nine_slice = 2,
};

pub const Color = extern struct {
    r: Byte,
    g: Byte,
    b: Byte,
    a: Byte,
};

pub const Image = extern struct {
    handle: Handle,
    w: u16,
    h: u16,
    region: [4]u16,
};

pub const NineSlice = extern struct {
    img: Image,
    l: u16,
    t: u16,
    r: u16,
    b: u16,
};

pub const StyleItemData = extern union {
    color: Color,
    image: Image,
    slice: NineSlice,
};

pub const StyleItem = extern struct {
    type: StyleItemType,
    data: StyleItemData,
};

pub const PasteFn = ?*const fn (Handle, [*c]TextEdit) callconv(.C) void;
pub const CopyFn = ?*const fn (Handle, [*c]const u8, c_int) callconv(.C) void;

pub const Clipboard = extern struct {
    userdata: Handle,
    paste: PasteFn,
    copy: CopyFn,
};

pub const Str = extern struct {
    buffer: Buffer,
    len: c_int,
};

pub const FilterFn = ?*const fn (*const TextEdit, Rune) callconv(.C) bool;

pub const TextUndoRecord = extern struct {
    where: c_int,
    insert_length: c_short,
    delete_length: c_short,
    char_storage: c_short,
};

pub const TextUndoState = extern struct {
    undo_rec: [99]TextUndoRecord,
    undo_char: [999]Rune,
    undo_point: c_short,
    redo_point: c_short,
    undo_char_point: c_short,
    redo_char_point: c_short,
};

pub const TextEdit = extern struct {
    clip: Clipboard,
    string: Str,
    filter: FilterFn,
    scrollbar: Vec2,
    cursor: c_int,
    select_start: c_int,
    select_end: c_int,
    mode: u8,
    cursor_at_end_of_line: u8,
    initialized: u8,
    has_preferred_x: u8,
    single_line: u8,
    active: u8,
    padding1: u8,
    preferred_x: f32,
    undo: TextUndoState,
};

pub const DrawList = extern struct {
    clip_rect: Rect,
    circle_vtx: [12]Vec2,
    config: ConvertConfig,
    buffer: [*c]Buffer,
    vertices: [*c]Buffer,
    elements: [*c]Buffer,
    element_count: c_uint,
    vertex_count: c_uint,
    cmd_count: c_uint,
    cmd_offset: usize,
    path_count: c_uint,
    path_offset: c_uint,
    line_AA: AntiAliasing,
    shape_AA: AntiAliasing,
};

pub const TextWidthFn = ?*const fn (Handle, f32, [*c]const u8, c_int) callconv(.C) f32;

pub const UserFontGlyph = extern struct {
    uv: [2]Vec2,
    offset: Vec2,
    width: f32,
    height: f32,
    xadvance: f32,
};

pub const QueryFontGlyphFn = ?*const fn (Handle, f32, [*c]UserFontGlyph, Rune, Rune) callconv(.C) void;

pub const UserFont = extern struct {
    userdata: Handle,
    height: f32,
    width: TextWidthFn,
    query: QueryFontGlyphFn,
    texture: Handle,
};

pub const PanelType = enum(c_uint) {
    none = 0,
    window = 1,
    group = 2,
    popup = 4,
    contextual = 16,
    combo = 32,
    menu = 64,
    tooltip = 128,
};

pub const Scroll = extern struct {
    x: u32,
    y: u32,
};

pub const MenuState = extern struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    offset: Scroll,
};

pub const PanelRowLayoutType = enum(c_uint) {
    dynamic_fixed = 0,
    dynamic_row = 1,
    dynamic_free = 2,
    dynamic = 3,
    static_fixed = 4,
    static_row = 5,
    static_free = 6,
    static = 7,
    template = 8,
};

pub const RowLayout = extern struct {
    type: PanelRowLayoutType,
    index: c_int,
    height: f32,
    min_height: f32,
    columns: c_int,
    ratio: [*c]const f32,
    item_width: f32,
    item_height: f32,
    item_offset: f32,
    filled: f32,
    item: Rect,
    tree_depth: c_int,
    templates: [16]f32,
};

pub const ChartType = enum(c_uint) {
    lines = 0,
    column = 1,
    // max = 2,
};

pub const ChartSlot = extern struct {
    type: ChartType,
    color: Color,
    highlight: Color,
    min: f32,
    max: f32,
    range: f32,
    count: c_int,
    last: Vec2,
    index: c_int,
    show_markers: bool,
};

pub const Chart = extern struct {
    slot: c_int,
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    slots: [4]ChartSlot,
};

pub const Panel = extern struct {
    type: PanelType,
    flags: Flags,
    bounds: Rect,
    offset_x: [*c]u32,
    offset_y: [*c]u32,
    at_x: f32,
    at_y: f32,
    max_x: f32,
    footer_height: f32,
    header_height: f32,
    border: f32,
    has_scrolling: c_uint,
    clip: Rect,
    menu: MenuState,
    row: RowLayout,
    chart: Chart,
    buffer: [*c]CommandBuffer,
    parent: [*c]Panel,
};

pub const Key = extern struct {
    down: bool,
    clicked: c_uint,
};

pub const Keyboard = extern struct {
    keys: [30]Key,
    text: [16]u8,
    text_len: c_int,
};

pub const MouseButton = extern struct {
    down: bool,
    clicked: c_uint,
    clicked_pos: Vec2,
};

pub const Mouse = extern struct {
    buttons: [4]MouseButton,
    pos: Vec2,
    prev: Vec2,
    delta: Vec2,
    scroll_delta: Vec2,
    grab: u8,
    grabbed: u8,
    ungrab: u8,
};

pub const Input = extern struct {
    keyboard: Keyboard,
    mouse: Mouse,
};

pub const Cursor = extern struct {
    img: Image,
    size: Vec2,
    offset: Vec2,
};

pub const StyleText = extern struct {
    color: Color,
    padding: Vec2,
    color_factor: f32,
    disabled_factor: f32,
};

pub const StyleButton = extern struct {
    normal: StyleItem,
    hover: StyleItem,
    active: StyleItem,
    border_color: Color,
    color_factor_background: f32,

    text_background: Color,
    text_normal: Color,
    text_hover: Color,
    text_active: Color,
    text_alignment: Flags,
    color_factor_text: f32,

    border: f32,
    rounding: f32,
    padding: Vec2,
    image_padding: Vec2,
    touch_padding: Vec2,
    disabled_factor: f32,

    userdata: Handle,
    draw_begin: ?*const fn ([*c]CommandBuffer, Handle) callconv(.C) void,
    draw_end: ?*const fn ([*c]CommandBuffer, Handle) callconv(.C) void,
};

pub const StyleToggle = extern struct {
    normal: StyleItem,
    hover: StyleItem,
    active: StyleItem,
    border_color: Color,
    cursor_normal: StyleItem,
    cursor_hover: StyleItem,
    text_normal: Color,
    text_hover: Color,
    text_active: Color,
    text_background: Color,
    text_alignment: Flags,
    padding: Vec2,
    touch_padding: Vec2,
    spacing: f32,
    border: f32,

    color_factor: f32,
    disabled_factor: f32,

    userdata: Handle,
    draw_begin: ?*const fn ([*c]CommandBuffer, Handle) callconv(.C) void,
    draw_end: ?*const fn ([*c]CommandBuffer, Handle) callconv(.C) void,
};

pub const StyleSelectable = extern struct {
    normal: StyleItem,
    hover: StyleItem,
    pressed: StyleItem,
    normal_active: StyleItem,
    hover_active: StyleItem,
    pressed_active: StyleItem,
    text_normal: Color,
    text_hover: Color,
    text_pressed: Color,
    text_normal_active: Color,
    text_hover_active: Color,
    text_pressed_active: Color,
    text_background: Color,
    text_alignment: Flags,
    rounding: f32,
    padding: Vec2,
    touch_padding: Vec2,
    image_padding: Vec2,

    color_factor: f32,
    disabled_factor: f32,

    userdata: Handle,
    draw_begin: ?*const fn ([*c]CommandBuffer, Handle) callconv(.C) void,
    draw_end: ?*const fn ([*c]CommandBuffer, Handle) callconv(.C) void,
};

pub const SymbolType = enum(c_uint) {
    none = 0,
    x = 1,
    underscore = 2,
    circle_solid = 3,
    circle_outline = 4,
    rect_solid = 5,
    rect_outline = 6,
    triangle_up = 7,
    triangle_down = 8,
    triangle_left = 9,
    triangle_right = 10,
    plus = 11,
    minus = 12,
    triangle_up_outline = 13,
    triangle_down_outline = 14,
    triangle_left_outline = 15,
    triangle_right_outline = 16,
};

pub const StyleSlider = extern struct {
    normal: StyleItem,
    hover: StyleItem,
    active: StyleItem,
    border_color: Color,
    bar_normal: Color,
    bar_hover: Color,
    bar_active: Color,
    bar_filled: Color,
    cursor_normal: StyleItem,
    cursor_hover: StyleItem,
    cursor_active: StyleItem,
    border: f32,
    rounding: f32,
    bar_height: f32,
    padding: Vec2,
    spacing: Vec2,
    cursor_size: Vec2,
    show_buttons: c_int,
    inc_button: StyleButton,
    dec_button: StyleButton,
    inc_symbol: SymbolType,
    dec_symbol: SymbolType,

    color_factor: f32,
    disabled_factor: f32,

    userdata: Handle,
    draw_begin: ?*const fn ([*c]CommandBuffer, Handle) callconv(.C) void,
    draw_end: ?*const fn ([*c]CommandBuffer, Handle) callconv(.C) void,
};

pub const StyleKnob = extern struct {
    normal: StyleItem,
    hover: StyleItem,
    active: StyleItem,
    border_color: Color,
    knob_normal: Color,
    knob_hover: Color,
    knob_active: Color,
    knob_border_color: Color,
    cursor_normal: Color,
    cursor_hover: Color,
    cursor_active: Color,
    border: f32,
    knob_border: f32,
    padding: Vec2,
    spacing: Vec2,
    cursor_width: f32,
    color_factor: f32,
    disabled_factor: f32,
    userdata: Handle,
    draw_begin: ?*const fn ([*c]CommandBuffer, Handle) callconv(.C) void,
    draw_end: ?*const fn ([*c]CommandBuffer, Handle) callconv(.C) void,
};

pub const StyleProgress = extern struct {
    normal: StyleItem,
    hover: StyleItem,
    active: StyleItem,
    border_color: Color,
    cursor_normal: StyleItem,
    cursor_hover: StyleItem,
    cursor_active: StyleItem,
    cursor_border_color: Color,
    rounding: f32,
    border: f32,
    cursor_border: f32,
    cursor_rounding: f32,
    padding: Vec2,

    color_factor: f32,
    disabled_factor: f32,

    userdata: Handle,
    draw_begin: ?*const fn ([*c]CommandBuffer, Handle) callconv(.C) void,
    draw_end: ?*const fn ([*c]CommandBuffer, Handle) callconv(.C) void,
};

pub const StyleScrollbar = extern struct {
    normal: StyleItem,
    hover: StyleItem,
    active: StyleItem,
    border_color: Color,
    cursor_normal: StyleItem,
    cursor_hover: StyleItem,
    cursor_active: StyleItem,
    cursor_border_color: Color,
    border: f32,
    rounding: f32,
    border_cursor: f32,
    rounding_cursor: f32,
    padding: Vec2,

    color_factor: f32,
    disabled_factor: f32,

    show_buttons: c_int,
    inc_button: StyleButton,
    dec_button: StyleButton,
    inc_symbol: SymbolType,
    dec_symbol: SymbolType,
    userdata: Handle,
    draw_begin: ?*const fn ([*c]CommandBuffer, Handle) callconv(.C) void,
    draw_end: ?*const fn ([*c]CommandBuffer, Handle) callconv(.C) void,
};

pub const StyleEdit = extern struct {
    normal: StyleItem,
    hover: StyleItem,
    active: StyleItem,
    border_color: Color,
    scrollbar: StyleScrollbar,
    cursor_normal: Color,
    cursor_hover: Color,
    cursor_text_normal: Color,
    cursor_text_hover: Color,
    text_normal: Color,
    text_hover: Color,
    text_active: Color,
    selected_normal: Color,
    selected_hover: Color,
    selected_text_normal: Color,
    selected_text_hover: Color,
    border: f32,
    rounding: f32,
    cursor_size: f32,
    scrollbar_size: Vec2,
    padding: Vec2,
    row_padding: f32,

    color_factor: f32,
    disabled_factor: f32,
};

pub const StyleProperty = extern struct {
    normal: StyleItem,
    hover: StyleItem,
    active: StyleItem,
    border_color: Color,
    label_normal: Color,
    label_hover: Color,
    label_active: Color,
    sym_left: SymbolType,
    sym_right: SymbolType,
    border: f32,
    rounding: f32,
    padding: Vec2,
    edit: StyleEdit,
    inc_button: StyleButton,
    dec_button: StyleButton,
    userdata: Handle,
    draw_begin: ?*const fn ([*c]CommandBuffer, Handle) callconv(.C) void,
    draw_end: ?*const fn ([*c]CommandBuffer, Handle) callconv(.C) void,
};

pub const StyleChart = extern struct {
    background: StyleItem,
    border_color: Color,
    selected_color: Color,
    color: Color,
    border: f32,
    rounding: f32,
    padding: Vec2,

    color_factor: f32,
    disabled_factor: f32,
    show_markers: bool,
};

pub const StyleTab = extern struct {
    background: StyleItem,
    border_color: Color,
    text: Color,
    tab_maximize_button: StyleButton,
    tab_minimize_button: StyleButton,
    node_maximize_button: StyleButton,
    node_minimize_button: StyleButton,
    sym_minimize: SymbolType,
    sym_maximize: SymbolType,
    border: f32,
    rounding: f32,
    indent: f32,
    padding: Vec2,
    spacing: Vec2,

    color_factor: f32,
    disabled_factor: f32,
};

pub const StyleCombo = extern struct {
    normal: StyleItem,
    hover: StyleItem,
    active: StyleItem,
    border_color: Color,
    label_normal: Color,
    label_hover: Color,
    label_active: Color,
    symbol_normal: Color,
    symbol_hover: Color,
    symbol_active: Color,
    button: StyleButton,
    sym_normal: SymbolType,
    sym_hover: SymbolType,
    sym_active: SymbolType,
    border: f32,
    rounding: f32,
    content_padding: Vec2,
    button_padding: Vec2,
    spacing: Vec2,

    color_factor: f32,
    disabled_factor: f32,
};

pub const NK_HEADER_LEFT: c_int = 0;
pub const NK_HEADER_RIGHT: c_int = 1;
pub const StyleHeaderAlign = c_uint;

pub const StyleWindowHeader = extern struct {
    normal: StyleItem,
    hover: StyleItem,
    active: StyleItem,
    close_button: StyleButton,
    minimize_button: StyleButton,
    close_symbol: SymbolType,
    minimize_symbol: SymbolType,
    maximize_symbol: SymbolType,
    label_normal: Color,
    label_hover: Color,
    label_active: Color,
    @"align": StyleHeaderAlign,
    padding: Vec2,
    label_padding: Vec2,
    spacing: Vec2,
};

pub const StyleWindow = extern struct {
    header: StyleWindowHeader,
    fixed_background: StyleItem,
    background: Color,
    border_color: Color,
    popup_border_color: Color,
    combo_border_color: Color,
    contextual_border_color: Color,
    menu_border_color: Color,
    group_border_color: Color,
    tooltip_border_color: Color,
    scaler: StyleItem,
    border: f32,
    combo_border: f32,
    contextual_border: f32,
    menu_border: f32,
    group_border: f32,
    tooltip_border: f32,
    popup_border: f32,
    min_row_height_padding: f32,
    rounding: f32,
    spacing: Vec2,
    scrollbar_size: Vec2,
    min_size: Vec2,
    padding: Vec2,
    group_padding: Vec2,
    popup_padding: Vec2,
    combo_padding: Vec2,
    contextual_padding: Vec2,
    menu_padding: Vec2,
    tooltip_padding: Vec2,
};

pub const Style = extern struct {
    font: [*c]const UserFont,
    cursors: [7][*c]const Cursor,
    cursor_active: [*c]const Cursor,
    cursor_last: [*c]Cursor,
    cursor_visible: c_int,
    text: StyleText,
    button: StyleButton,
    contextual_button: StyleButton,
    menu_button: StyleButton,
    option: StyleToggle,
    checkbox: StyleToggle,
    selectable: StyleSelectable,
    slider: StyleSlider,
    knob: StyleKnob,
    progress: StyleProgress,
    property: StyleProperty,
    edit: StyleEdit,
    chart: StyleChart,
    scrollh: StyleScrollbar,
    scrollv: StyleScrollbar,
    tab: StyleTab,
    combo: StyleCombo,
    window: StyleWindow,
};

pub const ButtonBehavior = enum(c_uint) {
    default = 0,
    repeater = 1,
};

pub const ConfigStackStyleItemElement = extern struct {
    address: [*c]StyleItem,
    old_value: StyleItem,
};

pub const ConfigStackStyleItem = extern struct {
    head: c_int,
    elements: [16]ConfigStackStyleItemElement,
};

pub const ConfigStackFloatElement = extern struct {
    address: [*c]f32,
    old_value: f32,
};

pub const ConfigStackFloat = extern struct {
    head: c_int,
    elements: [32]ConfigStackFloatElement,
};

pub const ConfigStackVec2Element = extern struct {
    address: [*c]Vec2,
    old_value: Vec2,
};

pub const ConfigStackVec2 = extern struct {
    head: c_int,
    elements: [16]ConfigStackVec2Element,
};

pub const ConfigStackFlagsElement = extern struct {
    address: [*c]Flags,
    old_value: Flags,
};

pub const ConfigStackFlags = extern struct {
    head: c_int,
    elements: [32]ConfigStackFlagsElement,
};

pub const struct_nk_config_stack_color_element = extern struct {
    address: [*c]Color,
    old_value: Color,
};

pub const ConfigStackColor = extern struct {
    head: c_int,
    elements: [32]struct_nk_config_stack_color_element,
};

pub const ConfigStackUserFontElement = extern struct {
    address: [*c][*c]const UserFont,
    old_value: [*c]const UserFont,
};

pub const struct_nk_config_stack_user_font = extern struct {
    head: c_int,
    elements: [8]ConfigStackUserFontElement,
};

pub const ConfigStackButtonBehaviorElement = extern struct {
    address: [*c]ButtonBehavior,
    old_value: ButtonBehavior,
};

pub const ConfigStackButtonBehavior = extern struct {
    head: c_int,
    elements: [8]ConfigStackButtonBehaviorElement,
};

pub const ConfigurationStacks = extern struct {
    style_items: ConfigStackStyleItem,
    floats: ConfigStackFloat,
    vectors: ConfigStackVec2,
    flags: ConfigStackFlags,
    colors: ConfigStackColor,
    fonts: struct_nk_config_stack_user_font,
    button_behaviors: ConfigStackButtonBehavior,
};
pub const Table = extern struct {
    seq: c_uint,
    size: c_uint,
    keys: [59]Hash,
    values: [59]u32,
    next: [*c]Table,
    prev: [*c]Table,
};

pub const PropertyState = extern struct {
    active: c_int,
    prev: c_int,
    buffer: [64]u8,
    length: c_int,
    cursor: c_int,
    select_start: c_int,
    select_end: c_int,
    name: Hash,
    seq: c_uint,
    old: c_uint,
    state: c_int,
};

pub const PopupBuffer = extern struct {
    begin: usize,
    parent: usize,
    last: usize,
    end: usize,
    active: bool,
};

pub const PopupState = extern struct {
    win: [*c]Window,
    type: PanelType,
    buf: PopupBuffer,
    name: Hash,
    active: bool,
    combo_count: c_uint,
    con_count: c_uint,
    con_old: c_uint,
    active_con: c_uint,
    header: Rect,
};

pub const EditState = extern struct {
    name: Hash,
    seq: c_uint,
    old: c_uint,
    active: c_int,
    prev: c_int,
    cursor: c_int,
    sel_start: c_int,
    sel_end: c_int,
    scrollbar: Scroll,
    mode: u8,
    single_line: u8,
};

pub const Window = extern struct {
    seq: c_uint,
    name: Hash,
    name_string: [64]u8,
    flags: Flags,
    bounds: Rect,
    scrollbar: Scroll,
    buffer: CommandBuffer,
    layout: [*c]Panel,
    scrollbar_hiding_timer: f32,
    property: PropertyState,
    popup: PopupState,
    edit: EditState,
    scrolled: c_uint,
    widgets_disabled: bool,
    tables: [*c]Table,
    table_count: c_uint,
    next: [*c]Window,
    prev: [*c]Window,
    parent: [*c]Window,
};

pub const PageData = extern union {
    tbl: Table,
    pan: Panel,
    win: Window,
};

pub const PageElement = extern struct {
    data: PageData,
    next: [*c]PageElement,
    prev: [*c]PageElement,
};

pub const Page = extern struct {
    size: c_uint,
    next: [*c]Page,
    win: [1]PageElement,
};

pub const Pool = extern struct {
    alloc: Allocator,
    type: AllocationType,
    page_count: c_uint,
    pages: [*c]Page,
    freelist: [*c]PageElement,
    capacity: c_uint,
    size: usize,
    cap: usize,
};

pub const StyleSlide = opaque {};

pub const ColorF = extern struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32,
};

pub const Vec2I = extern struct {
    x: c_short,
    y: c_short,
};

pub const RectI = extern struct {
    x: c_short,
    y: c_short,
    w: c_short,
    h: c_short,
};

pub const Glyph = [4]u8;

pub const Handle = extern union {
    ptr: ?*anyopaque,
    id: c_int,
};

pub const Heading = enum(c_uint) {
    up = 0,
    right = 1,
    down = 2,
    left = 3,
};

pub const Modify = enum(c_uint) {
    fixed = 0,
    modifiable = 1,
};

pub const Orientation = enum(c_uint) {
    vertical = 0,
    horizontal = 1,
};

pub const CollapseStates = enum(c_uint) {
    minimized = 0,
    maximized = 1,
};

pub const ShowStates = enum(c_uint) {
    hidden = 0,
    shown = 1,
};

pub const ChartEventFlags = packed struct(Flags) {
    hovering: bool = false,
    clicked: bool = false,

    __padding: u30 = 0,
};

pub const ColorFormat = enum(c_uint) {
    rgb = 0,
    rgba = 1,
};

pub const PopupType = enum(c_uint) {
    static = 0,
    dynamic = 1,
};

pub const LayoutFormat = enum(c_uint) {
    dynamic = 0,
    static = 1,
};

pub const TreeType = enum(c_uint) {
    node = 0,
    tab = 1,
};

pub const Keys = enum(c_uint) {
    none = 0,
    shift = 1,
    ctrl = 2,
    del = 3,
    enter = 4,
    tab = 5,
    backspace = 6,
    copy = 7,
    cut = 8,
    paste = 9,
    up = 10,
    down = 11,
    left = 12,
    right = 13,
    text_insert_mode = 14,
    text_replace_mode = 15,
    text_reset_mode = 16,
    text_line_start = 17,
    text_line_end = 18,
    text_start = 19,
    text_end = 20,
    text_undo = 21,
    text_redo = 22,
    text_select_all = 23,
    text_word_left = 24,
    text_word_right = 25,
    scroll_start = 26,
    scroll_end = 27,
    scroll_down = 28,
    scroll_up = 29,
};

pub const Buttons = enum(c_uint) {
    left = 0,
    middle = 1,
    right = 2,
    double = 3,
};

pub const ConvertResultFlags = packed struct(u32) {
    invalid_param: bool = false,
    command_buffer_full: bool = false,
    vertex_buffer_full: bool = false,
    element_buffer_full: bool = false,

    __padding: u28 = 0,

    pub const success = ConvertResultFlags{};
};

pub const CommandType = enum(c_uint) {
    nop = 0,
    scissor = 1,
    line = 2,
    curve = 3,
    rect = 4,
    rect_filled = 5,
    rect_multi_color = 6,
    circle = 7,
    circle_filled = 8,
    arc = 9,
    arc_filled = 10,
    triangle = 11,
    triangle_filled = 12,
    polygon = 13,
    polygon_filled = 14,
    polyline = 15,
    text = 16,
    image = 17,
    custom = 18,
};

pub const Command = extern struct {
    type: CommandType,
    next: usize,
};

pub const WindowFlags = packed struct(Flags) {
    // Panel
    border: bool = false,
    movable: bool = false,
    scalable: bool = false,
    closable: bool = false,
    minimizable: bool = false,
    no_scrollbar: bool = false,
    title: bool = false,
    scroll_auto_hide: bool = false,
    background: bool = false,
    scale_left: bool = false,
    no_input: bool = false,

    // window internal flags
    private_or_dynamic: bool = false,
    rom: bool = false,
    hidden: bool = false,
    closed: bool = false,
    minimized: bool = false,
    remove_rom: bool = false,

    __padding: u15 = 0,

    pub const default = WindowFlags{
        .border = true,
        .minimizable = true,
        .scalable = true,
        .movable = true,
    };
};

pub const WidgetLayoutStates = enum(c_uint) {
    invalid = 0,
    valid = 1,
    rom = 2,
    disabled = 3,
};

pub const NK_WIDGET_STATE_MODIFIED: c_int = 2;
pub const NK_WIDGET_STATE_INACTIVE: c_int = 4;
pub const NK_WIDGET_STATE_ENTERED: c_int = 8;
pub const NK_WIDGET_STATE_HOVER: c_int = 16;
pub const NK_WIDGET_STATE_ACTIVED: c_int = 32;
pub const NK_WIDGET_STATE_LEFT: c_int = 64;
pub const NK_WIDGET_STATE_HOVERED: c_int = 18;
pub const NK_WIDGET_STATE_ACTIVE: c_int = 34;
pub const WidgetStates = c_uint;

pub const TextAlignFlags = packed struct(Flags) {
    left: bool = false,
    centered: bool = false,
    right: bool = false,
    top: bool = false,
    middle: bool = false,
    bottom: bool = false,

    __padding: u26 = 0,

    pub const left = TextAlignFlags{
        .left = true,
        .middle = true,
    };
};

pub const EditFlags = packed struct(Flags) {
    read_only: bool = false,
    auto_select: bool = false,
    sig_enter: bool = false,
    allow_tab: bool = false,
    no_cursor: bool = false,
    selectable: bool = false,
    clipboard: bool = false,
    ctrl_enter_newline: bool = false,
    no_horizontal_scroll: bool = false,
    always_insert_mode: bool = false,
    multiline: bool = false,
    goto_end_on_activate: bool = false,

    __padding: u20 = 0,
};

pub const EditEventFlags = packed struct(Flags) {
    active: bool = false,
    inactive: bool = false,
    activated: bool = false,
    deactivated: bool = false,
    commited: bool = false,

    __padding: u27 = 0,
};

pub const StyleColors = enum(c_uint) {
    text = 0,
    window = 1,
    header = 2,
    border = 3,
    button = 4,
    button_hover = 5,
    button_active = 6,
    toggle = 7,
    toggle_hover = 8,
    toggle_cursor = 9,
    select = 10,
    select_active = 11,
    slider = 12,
    slider_cursor = 13,
    slider_cursor_hover = 14,
    slider_cursor_active = 15,
    property = 16,
    edit = 17,
    edit_cursor = 18,
    combo = 19,
    chart = 20,
    chart_color = 21,
    chart_color_highlight = 22,
    scrollbar = 23,
    scrollbar_cursor = 24,
    scrollbar_cursor_hover = 25,
    scrollbar_cursor_active = 26,
    tab_header = 27,
    knob = 28,
    knob_cursor = 29,
    knob_cursor_hover = 30,
    knob_cursor_active = 31,
};

pub const StyleCursor = enum(c_uint) {
    arrow = 0,
    text = 1,
    move = 2,
    resize_vertical = 3,
    resize_horizontal = 4,
    resize_top_left_down_right = 5,
    resize_top_right_down_left = 6,
};

pub const NK_COORD_UV: c_int = 0;
pub const NK_COORD_PIXEL: c_int = 1;
pub const FontCoordType = c_uint;

pub const BakedFont = extern struct {
    height: f32,
    ascent: f32,
    descent: f32,
    glyph_offset: Rune,
    glyph_count: Rune,
    ranges: [*c]const Rune,
};

pub const FontGlyph = extern struct {
    codepoint: Rune,
    xadvance: f32,
    x0: f32,
    y0: f32,
    x1: f32,
    y1: f32,
    w: f32,
    h: f32,
    u0: f32,
    v0: f32,
    u1: f32,
    v1: f32,
};

pub const FontConfig = extern struct {
    next: [*c]FontConfig,
    ttf_blob: ?*anyopaque,
    ttf_size: usize,
    ttf_data_owned_by_atlas: u8,
    merge_mode: u8,
    pixel_snap: u8,
    oversample_v: u8,
    oversample_h: u8,
    padding: [3]u8,
    size: f32,
    coord_type: FontCoordType,
    spacing: Vec2,
    range: [*c]const Rune,
    font: [*c]BakedFont,
    fallback_glyph: Rune,
    n: [*c]FontConfig,
    p: [*c]FontConfig,
};

pub const Font = extern struct {
    next: [*c]Font,
    handle: UserFont,
    info: BakedFont,
    scale: f32,
    glyphs: [*c]FontGlyph,
    fallback: [*c]const FontGlyph,
    fallback_codepoint: Rune,
    texture: Handle,
    config: [*c]FontConfig,
};

pub const FontAtlasFormat = enum(c_uint) {
    alpha8 = 0,
    rgba32 = 1,
};

pub const MemoryStatus = extern struct {
    memory: ?*anyopaque,
    type: c_uint,
    size: usize,
    allocated: usize,
    needed: usize,
    calls: usize,
};

pub const NK_BUFFER_FRONT: c_int = 0;
pub const NK_BUFFER_BACK: c_int = 1;
pub const NK_BUFFER_MAX: c_int = 2;
pub const BufferAllocationType = c_uint;

pub const NK_TEXT_EDIT_SINGLE_LINE: c_int = 0;
pub const NK_TEXT_EDIT_MULTI_LINE: c_int = 1;
pub const TextEditType = c_uint;

pub const NK_TEXT_EDIT_MODE_VIEW: c_int = 0;
pub const NK_TEXT_EDIT_MODE_INSERT: c_int = 1;
pub const NK_TEXT_EDIT_MODE_REPLACE: c_int = 2;
pub const TextEditMode = c_uint;

pub const CommandScissor = extern struct {
    header: Command,
    x: c_short,
    y: c_short,
    w: c_ushort,
    h: c_ushort,
};

pub const CommandLine = extern struct {
    header: Command,
    line_thickness: c_ushort,
    begin: Vec2I,
    end: Vec2I,
    color: Color,
};

pub const CommandCurve = extern struct {
    header: Command,
    line_thickness: c_ushort,
    begin: Vec2I,
    end: Vec2I,
    ctrl: [2]Vec2I,
    color: Color,
};

pub const CommandRect = extern struct {
    header: Command,
    rounding: c_ushort,
    line_thickness: c_ushort,
    x: c_short,
    y: c_short,
    w: c_ushort,
    h: c_ushort,
    color: Color,
};

pub const CommandRectFilled = extern struct {
    header: Command,
    rounding: c_ushort,
    x: c_short,
    y: c_short,
    w: c_ushort,
    h: c_ushort,
    color: Color,
};

pub const CommandRectMultiColor = extern struct {
    header: Command,
    x: c_short,
    y: c_short,
    w: c_ushort,
    h: c_ushort,
    left: Color,
    top: Color,
    bottom: Color,
    right: Color,
};

pub const CommandTriangle = extern struct {
    header: Command,
    line_thickness: c_ushort,
    a: Vec2I,
    b: Vec2I,
    c: Vec2I,
    color: Color,
};

pub const CommandTriangleFilled = extern struct {
    header: Command,
    a: Vec2I,
    b: Vec2I,
    c: Vec2I,
    color: Color,
};

pub const CommandCircle = extern struct {
    header: Command,
    x: c_short,
    y: c_short,
    line_thickness: c_ushort,
    w: c_ushort,
    h: c_ushort,
    color: Color,
};

pub const CommandCircleFilled = extern struct {
    header: Command,
    x: c_short,
    y: c_short,
    w: c_ushort,
    h: c_ushort,
    color: Color,
};

pub const CommandArc = extern struct {
    header: Command,
    cx: c_short,
    cy: c_short,
    r: c_ushort,
    line_thickness: c_ushort,
    a: [2]f32,
    color: Color,
};

pub const CommandArcFilled = extern struct {
    header: Command,
    cx: c_short,
    cy: c_short,
    r: c_ushort,
    a: [2]f32,
    color: Color,
};

pub const CommandPolygon = extern struct {
    header: Command,
    color: Color,
    line_thickness: c_ushort,
    point_count: c_ushort,
    points: [1]Vec2I,
};

pub const CommandPolygonFilled = extern struct {
    header: Command,
    color: Color,
    point_count: c_ushort,
    points: [1]Vec2I,
};

pub const CommandPolyline = extern struct {
    header: Command,
    color: Color,
    line_thickness: c_ushort,
    point_count: c_ushort,
    points: [1]Vec2I,
};

pub const CommandImage = extern struct {
    header: Command,
    x: c_short,
    y: c_short,
    w: c_ushort,
    h: c_ushort,
    img: Image,
    col: Color,
};

pub const CommandCustomCallbackFn = ?*const fn (?*anyopaque, c_short, c_short, c_ushort, c_ushort, Handle) callconv(.C) void;

pub const struct_nk_command_custom = extern struct {
    header: Command,
    x: c_short,
    y: c_short,
    w: c_ushort,
    h: c_ushort,
    callback_data: Handle,
    callback: CommandCustomCallbackFn,
};

pub const CommandText = extern struct {
    header: Command,
    font: [*c]const UserFont,
    background: Color,
    foreground: Color,
    x: c_short,
    y: c_short,
    w: c_ushort,
    h: c_ushort,
    height: f32,
    length: c_int,
    string: [1]u8,
};

pub const NK_CLIPPING_OFF: c_int = 0;
pub const NK_CLIPPING_ON: c_int = 1;
pub const CommandClipping = c_uint;

pub const DrawIndex = u16;

pub const NK_STROKE_OPEN: c_int = 0;
pub const NK_STROKE_CLOSED: c_int = 1;
pub const DrawListStroke = c_uint;

pub const NK_PANEL_SET_NONBLOCK: c_int = 240;
pub const NK_PANEL_SET_POPUP: c_int = 244;
pub const NK_PANEL_SET_SUB: c_int = 246;
pub const PanelSet = c_uint;

pub const utf_size = 4;
pub const utf_invalid = 0xFFFD;
pub const input_max = 16;
pub const max_number_buffer = 64;
pub const scrollbar_hiding_timeout = 4.0;
pub const textedit_undostatecount = 99;
pub const textedit_undocharcount = 999;
pub const max_layout_row_template_columns = 16;
pub const chart_max_slot = 4;
pub const window_max_name = 64;
pub const button_behavior_stack_size = 8;
pub const font_stack_size = 8;
pub const style_item_stack_size = 16;
pub const float_stack_size = 32;
pub const vector_stack_size = 16;
pub const flags_stack_size = 32;
pub const color_stack_size = 32;
pub const widget_disabled_factor = 0.5;

pub const WidgetAlignFlags = packed struct(u32) {
    left: bool = false,
    centered: bool = false,
    right: bool = false,
    top: bool = false,
    middle: bool = false,
    bottom: bool = false,

    __padding: u26 = 0,
};

// ---- Context ----
pub const Context = extern struct {
    input: Input = @import("std").mem.zeroes(Input),
    style: Style = @import("std").mem.zeroes(Style),
    memory: Buffer = @import("std").mem.zeroes(Buffer),
    clip: Clipboard = @import("std").mem.zeroes(Clipboard),
    last_widget_state: Flags = @import("std").mem.zeroes(Flags),
    button_behavior: ButtonBehavior = @import("std").mem.zeroes(ButtonBehavior),
    stacks: ConfigurationStacks = @import("std").mem.zeroes(ConfigurationStacks),
    delta_time_seconds: f32 = @import("std").mem.zeroes(f32),
    draw_list: DrawList = @import("std").mem.zeroes(DrawList),
    text_edit: TextEdit = @import("std").mem.zeroes(TextEdit),
    overlay: CommandBuffer = @import("std").mem.zeroes(CommandBuffer),
    build: c_int = @import("std").mem.zeroes(c_int),
    use_pool: c_int = @import("std").mem.zeroes(c_int),
    pool: Pool = @import("std").mem.zeroes(Pool),
    begin_ptr: [*c]Window = @import("std").mem.zeroes([*c]Window),
    end_ptr: [*c]Window = @import("std").mem.zeroes([*c]Window),
    active: [*c]Window = @import("std").mem.zeroes([*c]Window),
    current: [*c]Window = @import("std").mem.zeroes([*c]Window),
    freelist: [*c]PageElement = @import("std").mem.zeroes([*c]PageElement),
    count: c_uint = @import("std").mem.zeroes(c_uint),
    seq: c_uint = @import("std").mem.zeroes(c_uint),

    // ----------------------------------------------------------------------
    // initialization -------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn init(allocator: *const Allocator, font: ?*const UserFont) !Context {
        var ctx: Context = undefined;
        if (nk_init(&ctx, allocator, font)) {
            return ctx;
        } else {
            return error.ContextInitFailed;
        }
    }

    pub fn free(self: *Context) void {
        nk_free(self);
    }

    pub fn clear(self: *Context) void {
        nk_clear(self);
    }

    extern fn nk_init(*Context, *Allocator, ?*const UserFont) bool;
    extern fn nk_init_custom(*Context, cmds: *Buffer, pool: *Buffer, *const UserFont) bool;
    extern fn nk_clear(*Context) void;
    extern fn nk_free(*Context) void;

    // ----------------------------------------------------------------------
    // input ----------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn inputBegin(self: *Context) void {
        nk_input_begin(self);
    }

    pub fn inputEnd(self: *Context) void {
        nk_input_end(self);
    }

    pub fn inputMotion(self: *Context, x: c_int, y: c_int) void {
        nk_input_motion(self, x, y);
    }

    pub fn inputKey(self: *Context, key: Keys, down: bool) void {
        nk_input_key(self, key, down);
    }

    pub fn inputButton(self: *Context, btn: Buttons, x: c_int, y: c_int, down: bool) void {
        nk_input_button(self, btn, x, y, down);
    }

    pub fn inputScroll(self: *Context, val: Vec2) void {
        nk_input_scroll(self, val);
    }

    pub fn inputChar(self: *Context, val: u8) void {
        nk_input_char(self, val);
    }

    pub fn inputGlyph(self: *Context, val: [*]const u8) void {
        nk_input_glyph(self, val);
    }

    pub fn inputUnicode(self: *Context, val: Rune) void {
        nk_input_unicode(self, val);
    }

    extern fn nk_input_begin(*Context) void;
    extern fn nk_input_motion(*Context, x: c_int, y: c_int) void;
    extern fn nk_input_key(*Context, Keys, down: bool) void;
    extern fn nk_input_button(*Context, Buttons, x: c_int, y: c_int, down: bool) void;
    extern fn nk_input_scroll(*Context, val: Vec2) void;
    extern fn nk_input_char(*Context, u8) void;
    extern fn nk_input_glyph(*Context, [*]const u8) void;
    extern fn nk_input_unicode(*Context, Rune) void;
    extern fn nk_input_end(*Context) void;

    // ----------------------------------------------------------------------
    // Drawing -------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub const CommandIterator = struct {
        ctx: *Context,
        cmd: ?*const Command,

        pub fn init(ctx: *Context) CommandIterator {
            return .{
                .ctx = ctx,
                .cmd = nk__begin(ctx),
            };
        }

        pub fn next(self: *CommandIterator) ?*const Command {
            defer self.cmd = nk__next(self.ctx, self.cmd);
            return self.cmd;
        }

        extern fn nk__begin(*Context) ?*const Command;
        extern fn nk__next(*Context, ?*const Command) ?*const Command;
    };

    pub fn commandIterator(self: *Context) CommandIterator {
        return CommandIterator.init(self);
    }

    pub const DrawCommandIterator = struct {
        ctx: *const Context,
        cmd: ?*const DrawCommand,
        cmd_buffer: *const Buffer,

        pub fn init(ctx: *const Context, cmd_buffer: *const Buffer) DrawCommandIterator {
            return .{
                .ctx = ctx,
                .cmd = nk__draw_begin(ctx, cmd_buffer),
                .cmd_buffer = cmd_buffer,
            };
        }

        pub fn next(self: *DrawCommandIterator) ?*const DrawCommand {
            defer self.cmd = nk__draw_next(self.cmd, self.cmd_buffer, self.ctx);
            return self.cmd;
        }

        extern fn nk__draw_begin(*const Context, *const Buffer) ?*const DrawCommand;
        extern fn nk__draw_end(*const Context, *const Buffer) ?*const DrawCommand;
        extern fn nk__draw_next(?*const DrawCommand, *const Buffer, *const Context) ?*const DrawCommand;
    };

    pub fn drawCommandIterator(self: *const Context, cmd_buffer: *const Buffer) DrawCommandIterator {
        return DrawCommandIterator.init(self, cmd_buffer);
    }

    pub fn convert(self: *Context, cmds: *Buffer, vertices: *Buffer, elements: *Buffer, config: ConvertConfig) ConvertResultFlags {
        return nk_convert(self, cmds, vertices, elements, &config);
    }

    extern fn nk_convert(*Context, cmds: *Buffer, vertices: *Buffer, elements: *Buffer, *const ConvertConfig) ConvertResultFlags;

    // ----------------------------------------------------------------------
    // Window ---------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn begin(self: *Context, title: [*:0]const u8, bounds: Rect, flags: WindowFlags) bool {
        return nk_begin(self, title, bounds, flags);
    }

    pub fn beginTitled(self: *Context, name: [*:0]const u8, title: [*:0]const u8, bounds: Rect, flags: WindowFlags) bool {
        return nk_begin_titled(self, name, title, bounds, flags);
    }

    pub fn end(self: *Context) void {
        nk_end(self);
    }

    pub fn windowFind(self: *Context, name: [*:0]const u8) ?*Window {
        return nk_window_find(self, name);
    }

    pub fn windowGetBounds(self: *const Context) Rect {
        return nk_window_get_bounds(self);
    }

    pub fn windowGetPosition(self: *const Context) Vec2 {
        return nk_window_get_position(self);
    }

    pub fn windowGetSize(self: *const Context) Vec2 {
        return nk_window_get_position(self);
    }

    pub fn windowGetWidth(self: *const Context) f32 {
        return nk_window_get_width(self);
    }

    pub fn windowGetHeight(self: *const Context) f32 {
        return nk_window_get_height(self);
    }

    pub fn windowGetPanel(self: *Context) *Panel {
        return nk_window_get_panel(self);
    }

    pub fn windowGetContentRegion(self: *Context) Rect {
        return nk_window_get_content_region(self);
    }

    pub fn windowGetContentRegionMin(self: *Context) Vec2 {
        return nk_window_get_content_region_min(self);
    }

    pub fn windowGetContentRegionMax(self: *Context) Vec2 {
        return nk_window_get_content_region_max(self);
    }

    pub fn windowGetContentRegionSize(self: *Context) Vec2 {
        return nk_window_get_content_region_size(self);
    }

    pub fn windowGetCanvas(self: *Context) *CommandBuffer {
        return nk_window_get_canvas(self);
    }

    pub fn windowGetScroll(self: *Context, offset_x: *u32, offset_y: *u32) void {
        nk_window_get_scroll(self, offset_x, offset_y);
    }

    pub fn windowHasFocus(self: *const Context) bool {
        return nk_window_has_focus(self);
    }

    pub fn windowIsHovered(self: *Context) bool {
        return nk_window_is_hovered(self);
    }

    pub fn windowIsCollapsed(self: *Context, name: [*:0]const u8) bool {
        return nk_window_is_collapsed(self, name);
    }

    pub fn windowIsClosed(self: *Context, name: [*:0]const u8) bool {
        return nk_window_is_closed(self, name);
    }

    pub fn windowIsHidden(self: *Context, name: [*:0]const u8) bool {
        return nk_window_is_hidden(self, name);
    }

    pub fn windowIsActive(self: *Context, name: [*:0]const u8) bool {
        return nk_window_is_active(self, name);
    }

    pub fn windowIsAnyHovered(self: *Context) bool {
        return nk_window_is_any_hovered(self);
    }

    pub fn windowSetBounds(self: *Context, name: [*:0]const u8, bounds: Rect) void {
        nk_window_set_bounds(self, name, bounds);
    }

    pub fn windowSetPosition(self: *Context, name: [*:0]const u8, pos: Vec2) void {
        nk_window_set_position(self, name, pos);
    }

    pub fn windowSetSize(self: *Context, name: [*:0]const u8, size: Vec2) void {
        nk_window_set_size(self, name, size);
    }

    pub fn windowSetFocus(self: *Context, name: [*:0]const u8) void {
        nk_window_set_focus(self, name);
    }

    pub fn windowSetScroll(self: *Context, offset_x: u32, offset_y: u32) void {
        nk_window_set_scroll(self, offset_x, offset_y);
    }

    pub fn windowClose(self: *Context, name: [*:0]const u8) void {
        nk_window_close(self, name);
    }

    pub fn windowCollapse(self: *Context, name: [*:0]const u8, state: CollapseStates) void {
        windowCollapse(self, name, state);
    }

    pub fn windowCollapseIf(self: *Context, name: [*:0]const u8, state: CollapseStates, cond: c_int) void {
        nk_window_collapse_if(self, name, state, cond);
    }

    pub fn windowShow(self: *Context, name: [*:0]const u8, state: ShowStates) void {
        nk_window_show(self, name, state);
    }

    pub fn windowShowIf(self: *Context, name: [*:0]const u8, state: ShowStates, cond: c_int) void {
        nk_window_show_if(self, name, state, cond);
    }

    pub fn itemIsAnyActive(self: *Context) bool {
        return nk_item_is_any_active(self);
    }

    extern fn nk_begin(*Context, title: [*:0]const u8, bounds: Rect, flags: WindowFlags) bool;
    extern fn nk_begin_titled(*Context, name: [*:0]const u8, title: [*:0]const u8, bounds: Rect, flags: WindowFlags) bool;
    extern fn nk_end(*Context) void;
    extern fn nk_window_find(*Context, name: [*:0]const u8) ?*Window;
    extern fn nk_window_get_bounds(*const Context) Rect;
    extern fn nk_window_get_position(*const Context) Vec2;
    extern fn nk_window_get_size(*const Context) Vec2;
    extern fn nk_window_get_width(*const Context) f32;
    extern fn nk_window_get_height(*const Context) f32;
    extern fn nk_window_get_panel(*Context) *Panel;
    extern fn nk_window_get_content_region(*Context) Rect;
    extern fn nk_window_get_content_region_min(*Context) Vec2;
    extern fn nk_window_get_content_region_max(*Context) Vec2;
    extern fn nk_window_get_content_region_size(*Context) Vec2;
    extern fn nk_window_get_canvas(*Context) *CommandBuffer;
    extern fn nk_window_get_scroll(*Context, offset_x: *u32, offset_y: *u32) void;
    extern fn nk_window_has_focus(*const Context) bool;
    extern fn nk_window_is_hovered(*Context) bool;
    extern fn nk_window_is_collapsed(*Context, name: [*:0]const u8) bool;
    extern fn nk_window_is_closed(*Context, [*:0]const u8) bool;
    extern fn nk_window_is_hidden(*Context, [*:0]const u8) bool;
    extern fn nk_window_is_active(*Context, [*:0]const u8) bool;
    extern fn nk_window_is_any_hovered(*Context) bool;
    extern fn nk_window_set_bounds(*Context, name: [*:0]const u8, bounds: Rect) void;
    extern fn nk_window_set_position(*Context, name: [*:0]const u8, pos: Vec2) void;
    extern fn nk_window_set_size(*Context, name: [*:0]const u8, Vec2) void;
    extern fn nk_window_set_focus(*Context, name: [*:0]const u8) void;
    extern fn nk_window_set_scroll(*Context, offset_x: u32, offset_y: u32) void;
    extern fn nk_window_close(*Context, name: [*:0]const u8) void;
    extern fn nk_window_collapse(*Context, name: [*:0]const u8, state: CollapseStates) void;
    extern fn nk_window_collapse_if(*Context, name: [*:0]const u8, CollapseStates, cond: c_int) void;
    extern fn nk_window_show(*Context, name: [*:0]const u8, ShowStates) void;
    extern fn nk_window_show_if(*Context, name: [*:0]const u8, ShowStates, cond: c_int) void;
    extern fn nk_item_is_any_active(*Context) bool;

    // ----------------------------------------------------------------------
    // rule? ----------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn ruleHorizontal(self: *Context, color: Color, rounding: bool) void {
        nk_rule_horizontal(self, color, rounding);
    }
    extern fn nk_rule_horizontal(*Context, color: Color, rounding: bool) void;

    // ----------------------------------------------------------------------
    // Layouts --------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn layoutRowDynamic(self: *Context, height: f32, cols: c_int) void {
        nk_layout_row_dynamic(self, height, cols);
    }

    pub fn layoutRowStatic(self: *Context, height: f32, item_width: c_int, cols: c_int) void {
        nk_layout_row_static(self, height, item_width, cols);
    }

    pub fn layoutRowBegin(self: *Context, fmt: LayoutFormat, row_height: f32, cols: c_int) void {
        nk_layout_row_begin(self, fmt, row_height, cols);
    }

    pub fn layoutRowPush(self: *Context, value: f32) void {
        nk_layout_row_push(self, value);
    }

    pub fn layoutRowEnd(self: *Context) void {
        nk_layout_row_end(self);
    }

    pub fn layoutRow(self: *Context, layout: LayoutFormat, height: f32, ratios: []const f32) void {
        nk_layout_row(self, layout, height, @intCast(ratios.len), ratios.ptr);
    }

    pub fn layoutRowTemplateBegin(self: *Context, row_height: f32) void {
        nk_layout_row_template_begin(self, row_height);
    }

    pub fn layoutRowTemplatePushDynamic(self: *Context) void {
        nk_layout_row_template_push_dynamic(self);
    }

    pub fn layoutRowTemplatePushVariable(self: *Context, min_width: f32) void {
        nk_layout_row_template_push_variable(self, min_width);
    }

    pub fn layoutRowTemplatePushStatic(self: *Context, width: f32) void {
        nk_layout_row_template_push_static(self, width);
    }

    pub fn layoutRowTemplateEnd(self: *Context) void {
        nk_layout_row_template_end(self);
    }

    pub fn layoutSpaceBegin(self: *Context, layout: LayoutFormat, height: f32, widget_count: c_int) void {
        nk_layout_space_begin(self, layout, height, widget_count);
    }

    pub fn layoutSpacePush(self: *Context, bounds: Rect) void {
        nk_layout_space_push(self, bounds);
    }

    pub fn layoutSpaceEnd(self: *Context) void {
        nk_layout_space_end(self);
    }

    pub fn spacer(self: *Context) void {
        nk_spacer(self);
    }

    extern fn nk_layout_row_dynamic(*Context, height: f32, cols: c_int) void;
    extern fn nk_layout_row_static(*Context, height: f32, item_width: c_int, cols: c_int) void;
    extern fn nk_layout_row_begin(*Context, fmt: LayoutFormat, row_height: f32, cols: c_int) void;
    extern fn nk_layout_row_push(*Context, value: f32) void;
    extern fn nk_layout_row_end(*Context) void;
    extern fn nk_layout_row(*Context, LayoutFormat, height: f32, cols: c_int, ratio: [*]const f32) void;
    extern fn nk_layout_row_template_begin(*Context, row_height: f32) void;
    extern fn nk_layout_row_template_push_dynamic(*Context) void;
    extern fn nk_layout_row_template_push_variable(*Context, min_width: f32) void;
    extern fn nk_layout_row_template_push_static(*Context, width: f32) void;
    extern fn nk_layout_row_template_end(*Context) void;
    extern fn nk_layout_space_begin(*Context, LayoutFormat, height: f32, widget_count: c_int) void;
    extern fn nk_layout_space_push(*Context, bounds: Rect) void;
    extern fn nk_layout_space_end(*Context) void;

    extern fn nk_layout_space_bounds(*Context) Rect;
    extern fn nk_layout_set_min_row_height(*Context, height: f32) void;
    extern fn nk_layout_reset_min_row_height(*Context) void;
    extern fn nk_layout_widget_bounds(*Context) Rect;
    extern fn nk_layout_ratio_from_pixel(*Context, pixel_width: f32) f32;
    extern fn nk_layout_space_to_screen(*Context, Vec2) Vec2;
    extern fn nk_layout_space_to_local(*Context, Vec2) Vec2;
    extern fn nk_layout_space_rect_to_screen(*Context, Rect) Rect;
    extern fn nk_layout_space_rect_to_local(*Context, Rect) Rect;

    extern fn nk_spacer(*Context) void;

    // ----------------------------------------------------------------------
    // Widget ---------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn widget(self: *const Context, bounds: *Rect) WidgetLayoutStates {
        return nk_widget(bounds, self);
    }

    pub fn widgetFitting(self: *Context, bounds: *Rect, padding: Vec2) WidgetLayoutStates {
        return nk_widget_fitting(bounds, self, padding);
    }

    pub fn widgetBounds(self: *Context) Rect {
        return nk_widget_bounds(self);
    }

    pub fn widgetPosition(self: *Context) Vec2 {
        return nk_widget_position(self);
    }

    pub fn widgetSize(self: *Context) Vec2 {
        return nk_widget_size(self);
    }

    pub fn widgetWidth(self: *Context) f32 {
        return nk_widget_width(self);
    }

    pub fn widgetHeight(self: *Context) f32 {
        return nk_widget_height(self);
    }

    pub fn widgetIsHovered(self: *Context) bool {
        return nk_widget_is_hovered(self);
    }

    pub fn widgetIsMouseClicked(self: *Context, btn: Buttons) bool {
        return nk_widget_is_mouse_clicked(self, btn);
    }

    pub fn widgetHasMouseClickDown(self: *Context, btn: Buttons, down: bool) bool {
        return nk_widget_has_mouse_click_down(self, btn, down);
    }

    pub fn spacing(self: *Context, cols: c_int) void {
        nk_spacing(self, cols);
    }

    pub fn widgetDisableBegin(self: *Context) void {
        nk_widget_disable_begin(self);
    }

    pub fn widgetDisableEnd(self: *Context) void {
        nk_widget_disable_end(self);
    }

    extern fn nk_widget(*Rect, *const Context) WidgetLayoutStates;
    extern fn nk_widget_fitting(*Rect, *Context, Vec2) WidgetLayoutStates;
    extern fn nk_widget_bounds(*Context) Rect;
    extern fn nk_widget_position(*Context) Vec2;
    extern fn nk_widget_size(*Context) Vec2;
    extern fn nk_widget_width(*Context) f32;
    extern fn nk_widget_height(*Context) f32;
    extern fn nk_widget_is_hovered(*Context) bool;
    extern fn nk_widget_is_mouse_clicked(*Context, Buttons) bool;
    extern fn nk_widget_has_mouse_click_down(*Context, Buttons, down: bool) bool;
    extern fn nk_spacing(*Context, cols: c_int) void;
    extern fn nk_widget_disable_begin(*Context) void;
    extern fn nk_widget_disable_end(*Context) void;

    // ----------------------------------------------------------------------
    // Group ----------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn groupBegin(self: *Context, title: [*:0]const u8, flags: WindowFlags) bool {
        return nk_group_begin(self, title, flags);
    }

    pub fn groupBeginTitled(self: *Context, name: [*:0]const u8, title: [*:0]const u8, flags: WindowFlags) bool {
        return nk_group_begin_titled(self, name, title, flags);
    }

    pub fn groupEnd(self: *Context) void {
        nk_group_end(self);
    }

    pub fn groupScrolledOffsetBegin(self: *Context, x_offset: *u32, y_offset: *u32, title: [*:0]const u8, flags: WindowFlags) bool {
        return nk_group_scrolled_offset_begin(self, x_offset, y_offset, title, flags);
    }

    pub fn groupScrolledBegin(self: *Context, off: *Scroll, title: [*:0]const u8, flags: WindowFlags) bool {
        return nk_group_scrolled_begin(self, off, title, flags);
    }

    pub fn groupScrolledEnd(self: *Context) void {
        nk_group_scrolled_end(self);
    }

    pub fn groupGetScroll(self: *Context, id: [*:0]const u8, x_offset: *u32, y_offset: *u32) void {
        nk_group_get_scroll(self, id, x_offset, y_offset);
    }

    pub fn groupSetScroll(self: *Context, id: [*:0]const u8, x_offset: u32, y_offset: u32) void {
        nk_group_set_scroll(self, id, x_offset, y_offset);
    }

    extern fn nk_group_begin(*Context, title: [*:0]const u8, WindowFlags) bool;
    extern fn nk_group_begin_titled(*Context, name: [*:0]const u8, title: [*:0]const u8, WindowFlags) bool;
    extern fn nk_group_end(*Context) void;
    extern fn nk_group_scrolled_offset_begin(*Context, x_offset: *u32, y_offset: *u32, title: [*:0]const u8, flags: WindowFlags) bool;
    extern fn nk_group_scrolled_begin(*Context, off: *Scroll, title: [*:0]const u8, WindowFlags) bool;
    extern fn nk_group_scrolled_end(*Context) void;
    extern fn nk_group_get_scroll(*Context, id: [*:0]const u8, x_offset: *u32, y_offset: *u32) void;
    extern fn nk_group_set_scroll(*Context, id: [*:0]const u8, x_offset: u32, y_offset: u32) void;

    // ----------------------------------------------------------------------
    // Label ----------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn text(self: *Context, txt: []const u8, text_align: TextAlignFlags) void {
        nk_text(self, txt.ptr, @intCast(txt.len), text_align);
    }

    pub fn textColored(self: *Context, txt: []const u8, text_align: TextAlignFlags, col: Color) void {
        nk_text_colored(self, txt.ptr, @intCast(txt.len), text_align, col);
    }

    pub fn textWrap(self: *Context, txt: []const u8) void {
        nk_text_wrap(self, txt.ptr, @intCast(txt.len));
    }

    pub fn textWrapColored(self: *Context, txt: []const u8, col: Color) void {
        nk_text_wrap_colored(self, txt.ptr, @intCast(txt.len), col);
    }

    pub fn label(self: *Context, txt: [*:0]const u8, text_align: TextAlignFlags) void {
        nk_label(self, txt, text_align);
    }

    pub fn labelColored(self: *Context, txt: [*:0]const u8, text_align: TextAlignFlags, col: Color) void {
        nk_label_colored(self, txt, text_align, col);
    }

    pub fn labelWrap(self: *Context, txt: [*:0]const u8) void {
        nk_label_wrap(self, txt);
    }

    pub fn labelColoredWrap(self: *Context, txt: [*:0]const u8, col: Color) void {
        nk_label_colored_wrap(self, txt, col);
    }

    extern fn nk_text(*Context, [*]const u8, c_int, TextAlignFlags) void;
    extern fn nk_text_colored(*Context, [*]const u8, c_int, TextAlignFlags, Color) void;
    extern fn nk_text_wrap(*Context, [*]const u8, c_int) void;
    extern fn nk_text_wrap_colored(*Context, [*]const u8, c_int, Color) void;
    extern fn nk_label(*Context, [*:0]const u8, text_align: TextAlignFlags) void;
    extern fn nk_label_colored(*Context, [*:0]const u8, text_align: TextAlignFlags, Color) void;
    extern fn nk_label_wrap(*Context, [*:0]const u8) void;
    extern fn nk_label_colored_wrap(*Context, [*:0]const u8, Color) void;

    // ----------------------------------------------------------------------
    // button --------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn buttonText(self: *Context, title: []const u8) bool {
        return nk_button_text(self, title.ptr, @intCast(title.len));
    }

    pub fn buttonLabel(self: *Context, title: [*:0]const u8) bool {
        return nk_button_label(self, title);
    }

    pub fn buttonColor(self: *Context, col: Color) bool {
        return nk_button_color(self, col);
    }

    pub fn buttonSymbol(self: *Context, sym: SymbolType) bool {
        return nk_button_symbol(self, sym);
    }

    pub fn buttonImage(self: *Context, img: Image) bool {
        return nk_button_image(self, img);
    }

    pub fn buttonSymbolLabel(self: *Context, sym: SymbolType, title: [*:0]const u8, text_align: TextAlignFlags) bool {
        return nk_button_symbol_label(self, sym, title, text_align);
    }

    pub fn buttonSymbolText(self: *Context, sym: SymbolType, title: []const u8, text_align: TextAlignFlags) bool {
        return nk_button_symbol_text(self, sym, title.ptr, @intCast(title.len), text_align);
    }

    pub fn buttonImageLabel(self: *Context, img: Image, title: [*:0]const u8, text_align: TextAlignFlags) bool {
        return nk_button_image_label(self, img, title, text_align);
    }

    pub fn buttonImageText(self: *Context, img: Image, title: []const u8, text_align: TextAlignFlags) bool {
        return nk_button_image_text(self, img, title.ptr, @intCast(title.len), text_align);
    }

    pub fn buttonTextStyled(self: *Context, style: *const StyleButton, title: []const u8) bool {
        return nk_button_text_styled(self, style, title.ptr, @intCast(title.len));
    }

    pub fn buttonLabelStyled(self: *Context, style: *const StyleButton, title: [*:0]const u8) bool {
        return nk_button_label_styled(self, style, title);
    }

    pub fn buttonSymbolStyled(self: *Context, style: *const StyleButton, sym: SymbolType) bool {
        return nk_button_symbol_styled(self, style, sym);
    }

    pub fn buttonImageStyled(self: *Context, style: *const StyleButton, img: Image) bool {
        return nk_button_image_styled(self, style, img);
    }

    pub fn buttonSymbolTextStyled(self: *Context, style: *const StyleButton, sym: SymbolType, title: []const u8, text_align: TextAlignFlags) bool {
        return nk_button_symbol_text_styled(self, style, sym, title.ptr, @intCast(title.len), text_align);
    }

    pub fn buttonSymbolLabelStyled(self: *Context, style: *const StyleButton, sym: SymbolType, title: [*:0]const u8, text_align: TextAlignFlags) bool {
        return nk_button_symbol_label_styled(self, style, sym, title, text_align);
    }

    pub fn buttonImageLabelStyled(self: *Context, style: *const StyleButton, img: Image, title: [*:0]const u8, text_align: TextAlignFlags) bool {
        return nk_button_image_label_styled(self, style, img, title, text_align);
    }
    pub fn buttonImageTextStyled(self: *Context, style: *const StyleButton, img: Image, title: []const u8, text_align: TextAlignFlags) bool {
        return nk_button_image_text_styled(self, style, img, title.ptr, @intCast(title.len), text_align);
    }

    pub fn buttonSetBehavior(self: *Context, bhv: ButtonBehavior) void {
        nk_button_set_behavior(self, bhv);
    }

    pub fn buttonPushBehavior(self: *Context, bhv: ButtonBehavior) bool {
        return nk_button_push_behavior(self, bhv);
    }

    pub fn buttonPopBehavior(self: *Context) bool {
        return nk_button_pop_behavior(self);
    }

    extern fn nk_button_text(*Context, title: [*]const u8, len: c_int) bool;
    extern fn nk_button_label(*Context, title: [*:0]const u8) bool;
    extern fn nk_button_color(*Context, Color) bool;
    extern fn nk_button_symbol(*Context, SymbolType) bool;
    extern fn nk_button_image(*Context, img: Image) bool;
    extern fn nk_button_symbol_label(*Context, SymbolType, [*:0]const u8, text_align: TextAlignFlags) bool;
    extern fn nk_button_symbol_text(*Context, SymbolType, [*]const u8, c_int, text_align: TextAlignFlags) bool;
    extern fn nk_button_image_label(*Context, img: Image, [*:0]const u8, text_align: TextAlignFlags) bool;
    extern fn nk_button_image_text(*Context, img: Image, [*]const u8, c_int, text_align: TextAlignFlags) bool;
    extern fn nk_button_text_styled(*Context, *const StyleButton, title: [*]const u8, len: c_int) bool;
    extern fn nk_button_label_styled(*Context, *const StyleButton, title: [*:0]const u8) bool;
    extern fn nk_button_symbol_styled(*Context, *const StyleButton, SymbolType) bool;
    extern fn nk_button_image_styled(*Context, *const StyleButton, img: Image) bool;
    extern fn nk_button_symbol_text_styled(*Context, *const StyleButton, SymbolType, [*]const u8, c_int, text_align: TextAlignFlags) bool;
    extern fn nk_button_symbol_label_styled(*Context, style: *const StyleButton, symbol: SymbolType, title: [*:0]const u8, text_align: TextAlignFlags) bool;
    extern fn nk_button_image_label_styled(*Context, *const StyleButton, img: Image, [*:0]const u8, text_align: TextAlignFlags) bool;
    extern fn nk_button_image_text_styled(*Context, *const StyleButton, img: Image, [*]const u8, c_int, text_align: TextAlignFlags) bool;
    extern fn nk_button_set_behavior(*Context, ButtonBehavior) void;
    extern fn nk_button_push_behavior(*Context, ButtonBehavior) bool;
    extern fn nk_button_pop_behavior(*Context) bool;

    // ----------------------------------------------------------------------
    // List view ------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn listViewBegin(self: *Context, out: *ListView, id: [*:0]const u8, flags: WindowFlags, row_height: c_int, row_count: c_int) bool {
        return nk_list_view_begin(self, out, id, flags, row_height, row_count);
    }
    extern fn nk_list_view_begin(*Context, out: *ListView, id: [*:0]const u8, WindowFlags, row_height: c_int, row_count: c_int) bool;

    // ----------------------------------------------------------------------
    // Image ----------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn image(self: *Context, img: Image) void {
        nk_image(self, img);
    }

    pub fn imageColor(self: *Context, img: Image, col: Color) void {
        nk_image_color(self, img, col);
    }

    extern fn nk_image(*Context, Image) void;
    extern fn nk_image_color(*Context, Image, Color) void;

    // ----------------------------------------------------------------------
    // CheckBox -------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn checkLabel(self: *Context, title: [*:0]const u8, active: bool) bool {
        return nk_check_label(self, title, active);
    }

    pub fn checkText(self: *Context, title: []const u8, active: bool) bool {
        return nk_check_text(self, title.ptr, @intCast(title.len), active);
    }

    pub fn checkTextAlign(self: *Context, title: []const u8, active: bool, widget_alignment: WidgetAlignFlags, text_alignment: TextAlignFlags) bool {
        return nk_check_text_align(self, title.ptr, @intCast(title.len), active, widget_alignment, text_alignment);
    }

    pub fn checkFlagsLabel(self: *Context, title: [*:0]const u8, flags: c_uint, value: c_uint) c_uint {
        return nk_check_flags_label(self, title, flags, value);
    }

    pub fn checkFlagsText(self: *Context, title: []const u8, flags: c_uint, value: c_uint) c_uint {
        return nk_check_flags_text(self, title.ptr, @intCast(title.len), flags, value);
    }

    pub fn checkboxLabel(self: *Context, title: [*:0]const u8, active: *bool) bool {
        return nk_checkbox_label(self, title, active);
    }

    pub fn checkboxLabelAlign(self: *Context, title: [*:0]const u8, active: *bool, widget_alignment: WidgetAlignFlags, text_alignment: TextAlignFlags) bool {
        return nk_checkbox_label_align(self, title, active, widget_alignment, text_alignment);
    }

    pub fn checkboxText(self: *Context, title: []const u8, active: *bool) bool {
        return nk_checkbox_text(self, title.ptr, @intCast(title.len), active);
    }

    pub fn checkboxTextAlign(self: *Context, title: []const u8, active: *bool, widget_alignment: WidgetAlignFlags, text_alignment: TextAlignFlags) bool {
        return nk_checkbox_text_align(self, title.ptr, @intCast(title.len), active, widget_alignment, text_alignment);
    }

    pub fn checkboxFlagsLabel(self: *Context, title: [*:0]const u8, flags: *c_uint, value: c_uint) bool {
        return nk_checkbox_flags_label(self, title, flags, value);
    }

    pub fn checkboxFlagsText(self: *Context, title: []const u8, flags: *c_uint, value: c_uint) bool {
        return nk_checkbox_flags_text(self, title.ptr, @intCast(title.len), flags, value);
    }

    extern fn nk_check_label(*Context, [*:0]const u8, active: bool) bool;
    extern fn nk_check_text(*Context, [*]const u8, c_int, active: bool) bool;
    extern fn nk_check_text_align(*Context, [*]const u8, c_int, active: bool, widget_alignment: WidgetAlignFlags, text_alignment: TextAlignFlags) bool;
    extern fn nk_check_flags_label(*Context, [*:0]const u8, flags: c_uint, value: c_uint) c_uint;
    extern fn nk_check_flags_text(*Context, [*]const u8, c_int, flags: c_uint, value: c_uint) c_uint;
    extern fn nk_checkbox_label(*Context, [*:0]const u8, active: *bool) bool;
    extern fn nk_checkbox_label_align(*Context, [*:0]const u8, active: *bool, widget_alignment: WidgetAlignFlags, text_alignment: TextAlignFlags) bool;
    extern fn nk_checkbox_text(*Context, [*]const u8, c_int, active: *bool) bool;
    extern fn nk_checkbox_text_align(*Context, [*]const u8, c_int, active: *bool, widget_alignment: WidgetAlignFlags, text_alignment: TextAlignFlags) bool;
    extern fn nk_checkbox_flags_label(*Context, [*:0]const u8, flags: *c_uint, value: c_uint) bool;
    extern fn nk_checkbox_flags_text(*Context, [*]const u8, c_int, flags: *c_uint, value: c_uint) bool;

    // ----------------------------------------------------------------------
    // radio ----------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn radioLabel(self: *Context, title: [*:0]const u8, active: *bool) bool {
        return nk_radio_label(self, title, active);
    }

    pub fn radioLabelAlign(self: *Context, title: [*:0]const u8, active: *bool, widget_alignment: WidgetAlignFlags, text_alignment: TextAlignFlags) bool {
        return nk_radio_label_align(self, title, active, widget_alignment, text_alignment);
    }

    pub fn radioText(self: *Context, title: []const u8, active: *bool) bool {
        return nk_radio_text(self, title.ptr, @intCast(title.len), active);
    }

    pub fn radioTextAlign(self: *Context, title: []const u8, active: *bool, widget_alignment: WidgetAlignFlags, text_alignment: TextAlignFlags) bool {
        return nk_radio_text_align(self, title.ptr, @intCast(title.len), active, widget_alignment, text_alignment);
    }

    pub fn optionLabel(self: *Context, title: [*:0]const u8, active: bool) bool {
        return nk_option_label(self, title, active);
    }

    pub fn optionLabelAlign(self: *Context, title: [*:0]const u8, active: bool, widget_alignment: WidgetAlignFlags, text_alignment: TextAlignFlags) bool {
        return nk_option_label_align(self, title, active, widget_alignment, text_alignment);
    }

    pub fn optionText(self: *Context, title: []const u8, active: bool) bool {
        return nk_option_text(self, title.ptr, @intCast(title.len), active);
    }

    pub fn optionTextAlign(self: *Context, title: []const u8, active: bool, widget_alignment: WidgetAlignFlags, text_alignment: TextAlignFlags) bool {
        return nk_option_text_align(self, title.ptr, @intCast(title.len), active, widget_alignment, text_alignment);
    }

    extern fn nk_radio_label(*Context, [*:0]const u8, active: *bool) bool;
    extern fn nk_radio_label_align(*Context, [*:0]const u8, active: *bool, widget_alignment: WidgetAlignFlags, text_alignment: TextAlignFlags) bool;
    extern fn nk_radio_text(*Context, [*]const u8, c_int, active: *bool) bool;
    extern fn nk_radio_text_align(*Context, [*]const u8, c_int, active: *bool, widget_alignment: WidgetAlignFlags, text_alignment: TextAlignFlags) bool;

    extern fn nk_option_label(*Context, [*:0]const u8, active: bool) bool;
    extern fn nk_option_label_align(*Context, [*:0]const u8, active: bool, widget_alignment: WidgetAlignFlags, text_alignment: TextAlignFlags) bool;
    extern fn nk_option_text(*Context, [*]const u8, c_int, active: bool) bool;
    extern fn nk_option_text_align(*Context, [*]const u8, c_int, active: bool, widget_alignment: WidgetAlignFlags, text_alignment: TextAlignFlags) bool;

    // ----------------------------------------------------------------------
    // select ---------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn selectableLabel(self: *Context, title: [*:0]const u8, text_align: TextAlignFlags, value: *bool) bool {
        return nk_selectable_label(self, title, text_align, value);
    }

    pub fn selectableText(self: *Context, title: []const u8, text_align: TextAlignFlags, value: *bool) bool {
        return nk_selectable_text(self, title.ptr, @intCast(title.len), text_align, value);
    }

    pub fn selectableImageLabel(self: *Context, img: Image, title: [*:0]const u8, text_align: TextAlignFlags, value: *bool) bool {
        return nk_selectable_image_label(self, img, title, text_align, value);
    }

    pub fn selectableImageText(self: *Context, img: Image, title: []const u8, text_align: TextAlignFlags, value: *bool) bool {
        return nk_selectable_image_text(self, img, title.ptr, @intCast(title.len), text_align, value);
    }

    pub fn selectableSymbolLabel(self: *Context, sym: SymbolType, title: [*:0]const u8, text_align: TextAlignFlags, value: *bool) bool {
        return nk_selectable_symbol_label(self, sym, title, text_align, value);
    }

    pub fn selectableSymbolText(self: *Context, sym: SymbolType, title: []const u8, text_align: TextAlignFlags, value: *bool) bool {
        return nk_selectable_symbol_text(self, sym, title.ptr, @intCast(title.len), text_align, value);
    }

    pub fn selectLabel(self: *Context, title: [*:0]const u8, text_align: TextAlignFlags, value: bool) bool {
        return nk_select_label(self, title, text_align, value);
    }

    pub fn selectText(self: *Context, title: []const u8, text_align: TextAlignFlags, value: bool) bool {
        return nk_select_text(self, title.ptr, @intCast(title.len), text_align, value);
    }

    pub fn selectImageLabel(self: *Context, img: Image, title: [*:0]const u8, text_align: TextAlignFlags, value: bool) bool {
        return nk_select_image_label(self, img, title, text_align, value);
    }

    pub fn selectImageText(self: *Context, img: Image, title: []const u8, text_align: TextAlignFlags, value: bool) bool {
        return nk_select_image_text(self, img, title.ptr, @intCast(title.len), text_align, value);
    }

    pub fn selectSymbolLabel(self: *Context, sym: SymbolType, title: [*:0]const u8, text_align: TextAlignFlags, value: bool) bool {
        return nk_select_symbol_label(self, sym, title, text_align, value);
    }

    pub fn selectSymbolText(self: *Context, sym: SymbolType, title: []const u8, text_align: TextAlignFlags, value: bool) bool {
        return nk_select_symbol_text(self, sym, title.ptr, @intCast(title.len), text_align, value);
    }

    extern fn nk_selectable_label(*Context, [*:0]const u8, text_align: TextAlignFlags, value: *bool) bool;
    extern fn nk_selectable_text(*Context, [*]const u8, c_int, text_align: TextAlignFlags, value: *bool) bool;
    extern fn nk_selectable_image_label(*Context, Image, [*:0]const u8, text_align: TextAlignFlags, value: *bool) bool;
    extern fn nk_selectable_image_text(*Context, Image, [*]const u8, c_int, text_align: TextAlignFlags, value: *bool) bool;
    extern fn nk_selectable_symbol_label(*Context, SymbolType, [*:0]const u8, text_align: TextAlignFlags, value: *bool) bool;
    extern fn nk_selectable_symbol_text(*Context, SymbolType, [*]const u8, c_int, text_align: TextAlignFlags, value: *bool) bool;

    extern fn nk_select_label(*Context, [*:0]const u8, TextAlignFlags, value: bool) bool;
    extern fn nk_select_text(*Context, [*]const u8, c_int, TextAlignFlags, value: bool) bool;
    extern fn nk_select_image_label(*Context, Image, [*:0]const u8, TextAlignFlags, value: bool) bool;
    extern fn nk_select_image_text(*Context, Image, [*]const u8, c_int, TextAlignFlags, value: bool) bool;
    extern fn nk_select_symbol_label(*Context, SymbolType, [*:0]const u8, TextAlignFlags, value: bool) bool;
    extern fn nk_select_symbol_text(*Context, SymbolType, [*]const u8, c_int, TextAlignFlags, value: bool) bool;

    // ----------------------------------------------------------------------
    // Slider ---------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn slideFloat(self: *Context, min: f32, val: f32, max: f32, step: f32) f32 {
        return nk_slide_float(self, min, val, max, step);
    }

    pub fn slideInt(self: *Context, min: c_int, val: c_int, max: c_int, step: c_int) c_int {
        return nk_slide_int(self, min, val, max, step);
    }

    pub fn sliderFloat(self: *Context, min: f32, val: *f32, max: f32, step: f32) bool {
        return nk_slider_float(self, min, val, max, step);
    }

    pub fn sliderInt(self: *Context, min: c_int, val: *c_int, max: c_int, step: c_int) bool {
        return nk_slider_int(self, min, val, max, step);
    }

    extern fn nk_slide_float(*Context, min: f32, val: f32, max: f32, step: f32) f32;
    extern fn nk_slide_int(*Context, min: c_int, val: c_int, max: c_int, step: c_int) c_int;
    extern fn nk_slider_float(*Context, min: f32, val: *f32, max: f32, step: f32) bool;
    extern fn nk_slider_int(*Context, min: c_int, val: *c_int, max: c_int, step: c_int) bool;

    //------------------------------------------------------------------------
    // Knobs -----------------------------------------------------------------
    //------------------------------------------------------------------------

    pub fn knobFloat(self: *Context, min: f32, val: *f32, max: f32, step: f32, zero_direction: Heading, dead_zone_degrees: f32) bool {
        return nk_knob_float(self, min, val, max, step, zero_direction, dead_zone_degrees);
    }

    pub fn knobInt(self: *Context, min: c_int, val: *c_int, max: c_int, step: c_int, zero_direction: Heading, dead_zone_degrees: f32) bool {
        return nk_knob_int(self, min, val, max, step, zero_direction, dead_zone_degrees);
    }

    extern fn nk_knob_float(*Context, min: f32, val: *f32, max: f32, step: f32, zero_direction: Heading, dead_zone_degrees: f32) bool;
    extern fn nk_knob_int(*Context, min: c_int, val: *c_int, max: c_int, step: c_int, zero_direction: Heading, dead_zone_degrees: f32) bool;

    //-----------------------------------------------------------------------
    // Progress -------------------------------------------------------------
    //-----------------------------------------------------------------------

    pub fn progress(self: *Context, cur: *usize, max: usize, modifyable: bool) bool {
        return nk_progress(self, cur, max, modifyable);
    }

    pub fn prog(self: *Context, cur: usize, max: usize, modifyable: bool) usize {
        return nk_prog(self, cur, max, modifyable);
    }

    extern fn nk_progress(*Context, cur: *usize, max: usize, modifyable: bool) bool;
    extern fn nk_prog(*Context, cur: usize, max: usize, modifyable: bool) usize;

    // ----------------------------------------------------------------------
    // Color Picker ---------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn colorPicker(self: *Context, value: ColorF, format: ColorFormat) ColorF {
        return nk_color_picker(self, value, format);
    }

    pub fn colorPick(self: *Context, out: *ColorF, format: ColorFormat) bool {
        return nk_color_pick(self, out, format);
    }

    extern fn nk_color_picker(*Context, ColorF, ColorFormat) ColorF;
    extern fn nk_color_pick(*Context, *ColorF, ColorFormat) bool;

    // ----------------------------------------------------------------------
    // Property -------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn propertyInt(self: *Context, name: [*:0]const u8, min: c_int, val: *c_int, max: c_int, step: c_int, inc_per_pixel: f32) void {
        nk_property_int(self, name, min, val, max, step, inc_per_pixel);
    }

    pub fn propertyFloat(self: *Context, name: [*:0]const u8, min: f32, val: *f32, max: f32, step: f32, inc_per_pixel: f32) void {
        nk_property_float(self, name, min, val, max, step, inc_per_pixel);
    }

    pub fn propertyDouble(self: *Context, name: [*:0]const u8, min: f64, val: *f64, max: f64, step: f64, inc_per_pixel: f32) void {
        nk_property_double(self, name, min, val, max, step, inc_per_pixel);
    }

    pub fn propertyI(self: *Context, name: [*:0]const u8, min: c_int, val: c_int, max: c_int, step: c_int, inc_per_pixel: f32) c_int {
        return nk_propertyi(self, name, min, val, max, step, inc_per_pixel);
    }

    pub fn propertyF(self: *Context, name: [*:0]const u8, min: f32, val: f32, max: f32, step: f32, inc_per_pixel: f32) f32 {
        return nk_propertyf(self, name, min, val, max, step, inc_per_pixel);
    }

    pub fn propertyD(self: *Context, name: [*:0]const u8, min: f64, val: f64, max: f64, step: f64, inc_per_pixel: f32) f64 {
        return nk_propertyd(self, name, min, val, max, step, inc_per_pixel);
    }

    extern fn nk_property_int(*Context, name: [*:0]const u8, min: c_int, val: *c_int, max: c_int, step: c_int, inc_per_pixel: f32) void;
    extern fn nk_property_float(*Context, name: [*:0]const u8, min: f32, val: *f32, max: f32, step: f32, inc_per_pixel: f32) void;
    extern fn nk_property_double(*Context, name: [*:0]const u8, min: f64, val: *f64, max: f64, step: f64, inc_per_pixel: f32) void;
    extern fn nk_propertyi(*Context, name: [*:0]const u8, min: c_int, val: c_int, max: c_int, step: c_int, inc_per_pixel: f32) c_int;
    extern fn nk_propertyf(*Context, name: [*:0]const u8, min: f32, val: f32, max: f32, step: f32, inc_per_pixel: f32) f32;
    extern fn nk_propertyd(*Context, name: [*:0]const u8, min: f64, val: f64, max: f64, step: f64, inc_per_pixel: f32) f64;

    // ----------------------------------------------------------------------
    // Edit -----------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn editString(self: *Context, flags: EditFlags, buffer: []u8, len: *c_int, filter_fn: FilterFn) EditEventFlags {
        return nk_edit_string(self, flags, buffer.ptr, len, @intCast(buffer.len), filter_fn);
    }

    pub fn editStringZeroTerminated(self: *Context, flags: EditFlags, buffer: []u8, filter_fn: FilterFn) EditEventFlags {
        return nk_edit_string_zero_terminated(self, flags, buffer.ptr, @intCast(buffer.len), filter_fn);
    }

    pub fn editBuffer(self: *Context, flags: EditFlags, out: *TextEdit, filter_fn: FilterFn) EditEventFlags {
        return nk_edit_buffer(self, flags, out, filter_fn);
    }

    pub fn editFocus(self: *Context, flags: EditFlags) void {
        nk_edit_focus(self, flags);
    }

    pub fn editUnfocus(self: *Context) void {
        nk_edit_unfocus(self);
    }

    extern fn nk_edit_string(*Context, EditFlags, buffer: [*]u8, len: *c_int, max: c_int, FilterFn) EditEventFlags;
    extern fn nk_edit_string_zero_terminated(*Context, EditFlags, buffer: [*:0]u8, max: c_int, FilterFn) EditEventFlags;
    extern fn nk_edit_buffer(*Context, EditFlags, *TextEdit, FilterFn) EditEventFlags;
    extern fn nk_edit_focus(*Context, flags: EditFlags) void;
    extern fn nk_edit_unfocus(*Context) void;

    // ----------------------------------------------------------------------
    // Chart ----------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn chartBegin(self: *Context, ty: ChartType, num: c_int, min: f32, max: f32) bool {
        return nk_chart_begin(self, ty, num, min, max);
    }

    pub fn chartBeginColored(self: *Context, ty: ChartType, col: Color, active: Color, num: c_int, min: f32, max: f32) bool {
        return nk_chart_begin_colored(self, ty, col, active, num, min, max);
    }

    pub fn chartAddSlot(self: *Context, ty: ChartType, count: c_int, min_value: f32, max_value: f32) void {
        nk_chart_add_slot(self, ty, count, min_value, max_value);
    }

    pub fn chartAddSlotColored(self: *Context, ty: ChartType, col: Color, active: Color, count: c_int, min_value: f32, max_value: f32) void {
        nk_chart_add_slot_colored(self, ty, col, active, count, min_value, max_value);
    }

    pub fn chartPush(self: *Context, val: f32) ChartEventFlags {
        return nk_chart_push(self, val);
    }

    pub fn chartPushSlot(self: *Context, val: f32, slot: c_int) ChartEventFlags {
        return nk_chart_push_slot(self, val, slot);
    }

    pub fn chartEnd(self: *Context) void {
        nk_chart_end(self);
    }

    pub fn plot(self: *Context, ty: ChartType, values: []const f32, offset: c_int) void {
        nk_plot(self, ty, values.ptr, @intCast(values.len), offset);
    }

    pub fn plotFunction(self: *Context, ty: ChartType, userdata: ?*anyopaque, getter_fn: PlotValueGetterFn, count: c_int, offset: c_int) void {
        nk_plot_function(self, ty, userdata, getter_fn, count, offset);
    }

    extern fn nk_chart_begin(*Context, ChartType, num: c_int, min: f32, max: f32) bool;
    extern fn nk_chart_begin_colored(*Context, ChartType, Color, active: Color, num: c_int, min: f32, max: f32) bool;
    extern fn nk_chart_add_slot(*Context, ChartType, count: c_int, min_value: f32, max_value: f32) void;
    extern fn nk_chart_add_slot_colored(*Context, ChartType, Color, active: Color, count: c_int, min_value: f32, max_value: f32) void;
    extern fn nk_chart_push(*Context, f32) ChartEventFlags;
    extern fn nk_chart_push_slot(*Context, f32, c_int) ChartEventFlags;
    extern fn nk_chart_end(*Context) void;

    extern fn nk_plot(*Context, ChartType, values: [*]const f32, count: c_int, offset: c_int) void;

    pub const PlotValueGetterFn = ?*const fn (?*anyopaque, c_int) callconv(.C) f32;
    extern fn nk_plot_function(*Context, ChartType, userdata: ?*anyopaque, getter_fn: PlotValueGetterFn, count: c_int, offset: c_int) void;

    // ----------------------------------------------------------------------
    // popup ----------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn popupBegin(self: *Context, ty: PopupType, title: [*:0]const u8, flags: WindowFlags, bounds: Rect) bool {
        return nk_popup_begin(self, ty, title, flags, bounds);
    }

    pub fn popupClose(self: *Context) void {
        nk_popup_close(self);
    }

    pub fn popupEnd(self: *Context) void {
        nk_popup_end(self);
    }

    pub fn popupGetScroll(self: *Context, offset_x: *u32, offset_y: *u32) void {
        nk_popup_get_scroll(self, offset_x, offset_y);
    }

    pub fn popupSetScroll(self: *Context, offset_x: u32, offset_y: u32) void {
        nk_popup_set_scroll(self, offset_x, offset_y);
    }

    extern fn nk_popup_begin(*Context, PopupType, [*:0]const u8, WindowFlags, bounds: Rect) bool;
    extern fn nk_popup_close(*Context) void;
    extern fn nk_popup_end(*Context) void;
    extern fn nk_popup_get_scroll(*Context, offset_x: *u32, offset_y: *u32) void;
    extern fn nk_popup_set_scroll(*Context, offset_x: u32, offset_y: u32) void;

    // ----------------------------------------------------------------------
    // combo ----------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn combo(self: *Context, items: []const [*:0]const u8, selected: c_int, item_height: c_int, size: Vec2) c_int {
        return nk_combo(self, items.ptr, @intCast(items.len), selected, item_height, size);
    }

    pub fn comboSeparator(self: *Context, items_separated_by_separator: []const u8, separator: c_int, selected: c_int, item_height: c_int, size: Vec2) c_int {
        return nk_combo_separator(self, items_separated_by_separator.ptr, separator, selected, @intCast(items_separated_by_separator.len), item_height, size);
    }

    pub fn comboString(self: *Context, items_separated_by_zeros: []const u8, selected: c_int, item_height: c_int, size: Vec2) c_int {
        return nk_combo_string(self, items_separated_by_zeros.ptr, selected, @intCast(items_separated_by_zeros.len), item_height, size);
    }

    pub fn comboCallback(self: *Context, item_getter: ItemGetterFn, userdata: ?*anyopaque, selected: c_int, count: c_int, item_height: c_int, size: Vec2) c_int {
        return nk_combo_callback(self, item_getter, userdata, selected, count, item_height, size);
    }

    pub fn combobox(self: *Context, items: [][*:0]const u8, selected: *c_int, item_height: c_int, size: Vec2) void {
        nk_combobox(self, items.ptr, @intCast(items.len), selected, item_height, size);
    }

    pub fn comboboxString(self: *Context, items_separated_by_zeros: []const u8, selected: *c_int, item_height: c_int, size: Vec2) void {
        nk_combobox_string(self, items_separated_by_zeros.ptr, selected, @intCast(items_separated_by_zeros.len), item_height, size);
    }

    pub fn comboboxSeparator(self: *Context, items_separated_by_separator: []const u8, separator: c_int, selected: *c_int, item_height: c_int, size: Vec2) void {
        nk_combobox_separator(self, items_separated_by_separator.ptr, separator, selected, @intCast(items_separated_by_separator.len), item_height, size);
    }

    pub fn comboboxCallback(self: *Context, item_getter: ItemGetterFn, userdata: ?*anyopaque, selected: *c_int, count: c_int, item_height: c_int, size: Vec2) void {
        nk_combobox_callback(self, item_getter, userdata, selected, count, item_height, size);
    }

    pub fn comboBeginText(self: *Context, selected: []const u8, size: Vec2) bool {
        return nk_combo_begin_text(self, selected.ptr, @intCast(selected.len), size);
    }

    pub fn comboBeginLabel(self: *Context, selected: [*:0]const u8, size: Vec2) bool {
        return nk_combo_begin_label(self, selected, size);
    }

    pub fn comboBeginColor(self: *Context, color: Color, size: Vec2) bool {
        return nk_combo_begin_color(self, color, size);
    }

    pub fn comboBeginSymbol(self: *Context, sym: SymbolType, size: Vec2) bool {
        return nk_combo_begin_symbol(self, sym, size);
    }

    pub fn comboBeginSymbolLabel(self: *Context, selected: [*:0]const u8, sym: SymbolType, size: Vec2) bool {
        return nk_combo_begin_symbol_label(self, selected, sym, size);
    }

    pub fn comboBeginSymbolText(self: *Context, selected: []const u8, sym: SymbolType, size: Vec2) bool {
        return nk_combo_begin_symbol_text(self, selected.ptr, @intCast(selected.len), sym, size);
    }

    pub fn comboBeginImage(self: *Context, img: Image, size: Vec2) bool {
        return nk_combo_begin_image(self, img, size);
    }

    pub fn comboBeginImageLabel(self: *Context, selected: [*:0]const u8, img: Image, size: Vec2) bool {
        return nk_combo_begin_image_label(self, selected, img, size);
    }

    pub fn comboBeginImageText(self: *Context, selected: []const u8, img: Image, size: Vec2) bool {
        return nk_combo_begin_image_text(self, selected.ptr, @intCast(selected.len), img, size);
    }

    pub fn comboItemLabel(self: *Context, txt: [*:0]const u8, alignment: TextAlignFlags) bool {
        return nk_combo_item_label(self, txt, alignment);
    }

    pub fn comboItemText(self: *Context, txt: []const u8, alignment: TextAlignFlags) bool {
        return nk_combo_item_text(self, txt.ptr, @intCast(txt.len), alignment);
    }

    pub fn comboItemImageLabel(self: *Context, img: Image, txt: [*:0]const u8, alignment: TextAlignFlags) bool {
        return nk_combo_item_image_label(self, img, txt, alignment);
    }

    pub fn comboItemImageText(self: *Context, img: Image, txt: []const u8, alignment: TextAlignFlags) bool {
        return nk_combo_item_image_text(self, img, txt.ptr, @intCast(txt.len), alignment);
    }

    pub fn comboItemSymbolLabel(self: *Context, sym: SymbolType, txt: [*:0]const u8, alignment: TextAlignFlags) bool {
        return nk_combo_item_symbol_label(self, sym, txt, alignment);
    }

    pub fn comboItemSymbolText(self: *Context, sym: SymbolType, txt: []const u8, alignment: TextAlignFlags) bool {
        return nk_combo_item_symbol_text(self, sym, txt.ptr, @intCast(txt.len), alignment);
    }

    pub fn comboClose(self: *Context) void {
        nk_combo_close(self);
    }

    pub fn comboEnd(self: *Context) void {
        nk_combo_end(self);
    }

    extern fn nk_combo(*Context, items: [*]const [*:0]const u8, count: c_int, selected: c_int, item_height: c_int, size: Vec2) c_int;
    extern fn nk_combo_separator(*Context, items_separated_by_separator: [*]const u8, separator: c_int, selected: c_int, count: c_int, item_height: c_int, size: Vec2) c_int;
    extern fn nk_combo_string(*Context, items_separated_by_zeros: [*]const u8, selected: c_int, count: c_int, item_height: c_int, size: Vec2) c_int;

    const ItemGetterFn = ?*const fn (?*anyopaque, c_int, ?[*][*:0]const u8) callconv(.C) void;
    extern fn nk_combo_callback(*Context, item_getter: ItemGetterFn, userdata: ?*anyopaque, selected: c_int, count: c_int, item_height: c_int, size: Vec2) c_int;

    extern fn nk_combobox(*Context, items: [*][*:0]const u8, count: c_int, selected: *c_int, item_height: c_int, size: Vec2) void;
    extern fn nk_combobox_string(*Context, items_separated_by_zeros: [*]const u8, selected: *c_int, count: c_int, item_height: c_int, size: Vec2) void;
    extern fn nk_combobox_separator(*Context, items_separated_by_separator: [*]const u8, separator: c_int, selected: *c_int, count: c_int, item_height: c_int, size: Vec2) void;
    extern fn nk_combobox_callback(*Context, item_getter: ItemGetterFn, ?*anyopaque, selected: *c_int, count: c_int, item_height: c_int, size: Vec2) void;

    extern fn nk_combo_begin_text(*Context, selected: [*]const u8, c_int, size: Vec2) bool;
    extern fn nk_combo_begin_label(*Context, selected: [*:0]const u8, size: Vec2) bool;
    extern fn nk_combo_begin_color(*Context, color: Color, size: Vec2) bool;
    extern fn nk_combo_begin_symbol(*Context, SymbolType, size: Vec2) bool;
    extern fn nk_combo_begin_symbol_label(*Context, selected: [*:0]const u8, SymbolType, size: Vec2) bool;
    extern fn nk_combo_begin_symbol_text(*Context, selected: [*]const u8, c_int, SymbolType, size: Vec2) bool;
    extern fn nk_combo_begin_image(*Context, img: Image, size: Vec2) bool;
    extern fn nk_combo_begin_image_label(*Context, selected: [*:0]const u8, Image, size: Vec2) bool;
    extern fn nk_combo_begin_image_text(*Context, selected: [*]const u8, c_int, Image, size: Vec2) bool;
    extern fn nk_combo_item_label(*Context, [*:0]const u8, alignment: TextAlignFlags) bool;
    extern fn nk_combo_item_text(*Context, [*]const u8, c_int, alignment: TextAlignFlags) bool;
    extern fn nk_combo_item_image_label(*Context, Image, [*:0]const u8, alignment: TextAlignFlags) bool;
    extern fn nk_combo_item_image_text(*Context, Image, [*]const u8, c_int, alignment: TextAlignFlags) bool;
    extern fn nk_combo_item_symbol_label(*Context, SymbolType, [*:0]const u8, alignment: TextAlignFlags) bool;
    extern fn nk_combo_item_symbol_text(*Context, SymbolType, [*]const u8, c_int, alignment: TextAlignFlags) bool;
    extern fn nk_combo_close(*Context) void;
    extern fn nk_combo_end(*Context) void;

    // ----------------------------------------------------------------------
    // Contextual -----------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn contextualBegin(self: *Context, flags: WindowFlags, size: Vec2, trigger_bounds: Rect) bool {
        return nk_contextual_begin(self, flags, size, trigger_bounds);
    }

    pub fn contextualItemText(self: *Context, txt: []const u8, text_align: TextAlignFlags) bool {
        return nk_contextual_item_text(self, txt.ptr, @intCast(txt.len), text_align);
    }

    pub fn contextualItemLabel(self: *Context, txt: [*:0]const u8, text_align: TextAlignFlags) bool {
        return nk_contextual_item_label(self, txt, text_align);
    }

    pub fn contextualItemImageLabel(self: *Context, img: Image, txt: [*:0]const u8, alignment: TextAlignFlags) bool {
        return nk_contextual_item_image_label(self, img, txt, alignment);
    }

    pub fn contextualItemImageText(self: *Context, img: Image, txt: []const u8, alignment: TextAlignFlags) bool {
        return nk_contextual_item_image_text(self, img, txt.ptr, @intCast(txt.len), alignment);
    }

    pub fn contextualItemSymbolLabel(self: *Context, sym: SymbolType, txt: [*:0]const u8, alignment: TextAlignFlags) bool {
        return nk_contextual_item_symbol_label(self, sym, txt, alignment);
    }

    pub fn contextualItemSymbolText(self: *Context, sym: SymbolType, txt: []const u8, alignment: TextAlignFlags) bool {
        return nk_contextual_item_symbol_text(self, sym, txt.ptr, @intCast(txt.len), alignment);
    }

    pub fn contextualClose(self: *Context) void {
        nk_contextual_close(self);
    }

    pub fn contextualEnd(self: *Context) void {
        nk_contextual_end(self);
    }

    extern fn nk_contextual_begin(*Context, WindowFlags, Vec2, trigger_bounds: Rect) bool;
    extern fn nk_contextual_item_text(*Context, [*]const u8, c_int, text_align: TextAlignFlags) bool;
    extern fn nk_contextual_item_label(*Context, [*:0]const u8, text_align: TextAlignFlags) bool;
    extern fn nk_contextual_item_image_label(*Context, Image, [*:0]const u8, alignment: TextAlignFlags) bool;
    extern fn nk_contextual_item_image_text(*Context, Image, [*]const u8, len: c_int, alignment: TextAlignFlags) bool;
    extern fn nk_contextual_item_symbol_label(*Context, SymbolType, [*:0]const u8, alignment: TextAlignFlags) bool;
    extern fn nk_contextual_item_symbol_text(*Context, SymbolType, [*]const u8, c_int, alignment: TextAlignFlags) bool;
    extern fn nk_contextual_close(*Context) void;
    extern fn nk_contextual_end(*Context) void;

    // ----------------------------------------------------------------------
    // Tooltip --------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn tooltip(self: *Context, txt: [*:0]const u8) void {
        nk_tooltip(self, txt);
    }

    pub fn tooltipBegin(self: *Context, width: f32) bool {
        return nk_tooltip_begin(self, width);
    }

    pub fn tooltipEnd(self: *Context) void {
        nk_tooltip_end(self);
    }

    extern fn nk_tooltip(*Context, [*:0]const u8) void;
    extern fn nk_tooltip_begin(*Context, width: f32) bool;
    extern fn nk_tooltip_end(*Context) void;

    // ----------------------------------------------------------------------
    // Menu -----------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn menubarBegin(self: *Context) void {
        nk_menubar_begin(self);
    }

    pub fn menubarEnd(self: *Context) void {
        nk_menubar_end(self);
    }

    pub fn menuBeginText(self: *Context, title: []const u8, text_align: TextAlignFlags, size: Vec2) bool {
        return nk_menu_begin_text(self, title.ptr, @intCast(title.len), text_align, size);
    }

    pub fn menuBeginLabel(self: *Context, title: [*:0]const u8, text_align: TextAlignFlags, size: Vec2) bool {
        return nk_menu_begin_label(self, title, text_align, size);
    }

    pub fn menuBeginImage(self: *Context, id: [*:0]const u8, img: Image, size: Vec2) bool {
        return nk_menu_begin_image(self, id, img, size);
    }

    pub fn menuBeginImageText(self: *Context, title: []const u8, text_align: TextAlignFlags, img: Image, size: Vec2) bool {
        return nk_menu_begin_image_text(self, title.ptr, @intCast(title.len), text_align, img, size);
    }

    pub fn menuBeginImageLabel(self: *Context, title: [*:0]const u8, text_align: TextAlignFlags, img: Image, size: Vec2) bool {
        return nk_menu_begin_image_label(self, title, text_align, img, size);
    }

    pub fn menuBeginSymbol(self: *Context, id: [*:0]const u8, sym: SymbolType, size: Vec2) bool {
        return nk_menu_begin_symbol(self, id, sym, size);
    }

    pub fn menuBeginSymbolText(self: *Context, title: []const u8, text_align: TextAlignFlags, sym: SymbolType, size: Vec2) bool {
        return nk_menu_begin_symbol_text(self, title.ptr, @intCast(title.len), text_align, sym, size);
    }

    pub fn menuBeginSymbolLabel(self: *Context, title: [*:0]const u8, text_align: TextAlignFlags, sym: SymbolType, size: Vec2) bool {
        return nk_menu_begin_symbol_label(self, title, text_align, sym, size);
    }

    pub fn menuItemText(self: *Context, title: []const u8, text_align: TextAlignFlags) bool {
        return nk_menu_item_text(self, title.ptr, @intCast(title.len), text_align);
    }

    pub fn menuItemLabel(self: *Context, title: [*:0]const u8, text_align: TextAlignFlags) bool {
        return nk_menu_item_label(self, title, text_align);
    }

    pub fn menuItemImageLabel(self: *Context, img: Image, title: [*:0]const u8, text_align: TextAlignFlags) bool {
        return nk_menu_item_image_label(self, img, title, text_align);
    }

    pub fn menuItemImageText(self: *Context, img: Image, title: []const u8, text_align: TextAlignFlags) bool {
        return nk_menu_item_image_text(self, img, title.ptr, @intCast(title.len), text_align);
    }

    pub fn menuItemSymbolText(self: *Context, sym: SymbolType, title: []const u8, text_align: TextAlignFlags) bool {
        return nk_menu_item_symbol_text(self, sym, title.ptr, @intCast(title.len), text_align);
    }

    pub fn menuItemSymbolLabel(self: *Context, sym: SymbolType, title: [*:0]const u8, text_align: TextAlignFlags) bool {
        return nk_menu_item_symbol_label(self, sym, title, text_align);
    }

    pub fn menuClose(self: *Context) void {
        nk_menu_close(self);
    }

    pub fn menuEnd(self: *Context) void {
        nk_menu_end(self);
    }

    extern fn nk_menubar_begin(*Context) void;
    extern fn nk_menubar_end(*Context) void;

    extern fn nk_menu_begin_text(*Context, title: [*]const u8, title_len: c_int, text_align: TextAlignFlags, size: Vec2) bool;
    extern fn nk_menu_begin_label(*Context, [*:0]const u8, text_align: TextAlignFlags, size: Vec2) bool;
    extern fn nk_menu_begin_image(*Context, [*]const u8, Image, size: Vec2) bool;
    extern fn nk_menu_begin_image_text(*Context, [*]const u8, c_int, text_align: TextAlignFlags, Image, size: Vec2) bool;
    extern fn nk_menu_begin_image_label(*Context, [*:0]const u8, text_align: TextAlignFlags, Image, size: Vec2) bool;
    extern fn nk_menu_begin_symbol(*Context, [*:0]const u8, SymbolType, size: Vec2) bool;
    extern fn nk_menu_begin_symbol_text(*Context, [*]const u8, c_int, text_align: TextAlignFlags, SymbolType, size: Vec2) bool;
    extern fn nk_menu_begin_symbol_label(*Context, [*c]const u8, text_align: TextAlignFlags, SymbolType, size: Vec2) bool;
    extern fn nk_menu_item_text(*Context, [*]const u8, c_int, text_align: TextAlignFlags) bool;
    extern fn nk_menu_item_label(*Context, [*:0]const u8, text_align: TextAlignFlags) bool;
    extern fn nk_menu_item_image_label(*Context, Image, [*:0]const u8, text_align: TextAlignFlags) bool;
    extern fn nk_menu_item_image_text(*Context, Image, [*]const u8, len: c_int, text_align: TextAlignFlags) bool;
    extern fn nk_menu_item_symbol_text(*Context, SymbolType, [*]const u8, c_int, text_align: TextAlignFlags) bool;
    extern fn nk_menu_item_symbol_label(*Context, SymbolType, [*:0]const u8, text_align: TextAlignFlags) bool;
    extern fn nk_menu_close(*Context) void;
    extern fn nk_menu_end(*Context) void;

    // ----------------------------------------------------------------------
    // Tree -----------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn treePushHashed(self: *Context, ty: TreeType, title: [*:0]const u8, initial_state: CollapseStates, hash: []const u8, seed: c_int) bool {
        return nk_tree_push_hashed(self, ty, title, initial_state, hash.ptr, @intCast(hash.len), seed);
    }

    pub fn treeImagePushHashed(self: *Context, ty: TreeType, img: Image, title: [*:0]const u8, initial_state: CollapseStates, hash: []const u8, seed: c_int) bool {
        return nk_tree_image_push_hashed(self, ty, img, title, initial_state, hash.ptr, @intCast(hash.len), seed);
    }

    pub fn treePop(self: *Context) void {
        nk_tree_pop(self);
    }

    pub fn treeStatePush(self: *Context, ty: TreeType, title: [*:0]const u8, state: *CollapseStates) bool {
        return nk_tree_state_push(self, ty, title, state);
    }

    pub fn treeStateImagePush(self: *Context, ty: TreeType, img: Image, title: [*:0]const u8, state: *CollapseStates) bool {
        return nk_tree_state_image_push(self, ty, img, title, state);
    }

    pub fn treeStatePop(self: *Context) void {
        nk_tree_state_pop(self);
    }

    pub fn treeElementPushHashed(self: *Context, ty: TreeType, title: [*:0]const u8, initial_state: CollapseStates, selected: *bool, hash: []const u8, seed: c_int) bool {
        return nk_tree_element_push_hashed(self, ty, title, initial_state, selected, hash.ptr, @intCast(hash.len), seed);
    }

    pub fn treeElementImagePushHashed(self: *Context, ty: TreeType, img: Image, title: [*:0]const u8, initial_state: CollapseStates, selected: *bool, hash: []const u8, seed: c_int) bool {
        return nk_tree_element_image_push_hashed(self, ty, img, title, initial_state, selected, hash.ptr, @intCast(hash.len), seed);
    }

    pub fn treeElementPop(self: *Context) void {
        nk_tree_element_pop(self);
    }

    extern fn nk_tree_push_hashed(*Context, TreeType, title: [*:0]const u8, initial_state: CollapseStates, hash: [*]const u8, len: c_int, seed: c_int) bool;
    extern fn nk_tree_image_push_hashed(*Context, TreeType, Image, title: [*:0]const u8, initial_state: CollapseStates, hash: [*]const u8, len: c_int, seed: c_int) bool;
    extern fn nk_tree_pop(*Context) void;
    extern fn nk_tree_state_push(*Context, TreeType, title: [*:0]const u8, state: *CollapseStates) bool;
    extern fn nk_tree_state_image_push(*Context, TreeType, Image, title: [*:0]const u8, state: *CollapseStates) bool;
    extern fn nk_tree_state_pop(*Context) void;
    extern fn nk_tree_element_push_hashed(*Context, TreeType, title: [*:0]const u8, initial_state: CollapseStates, selected: *bool, hash: [*]const u8, len: c_int, seed: c_int) bool;
    extern fn nk_tree_element_image_push_hashed(*Context, TreeType, Image, title: [*:0]const u8, initial_state: CollapseStates, selected: *bool, hash: [*]const u8, len: c_int, seed: c_int) bool;
    extern fn nk_tree_element_pop(*Context) void;

    // ----------------------------------------------------------------------
    // Style ----------------------------------------------------------------
    // ----------------------------------------------------------------------

    pub fn styleDefault(self: *Context) void {
        nk_style_default(self);
    }

    pub fn styleFromTable(self: *Context, colors: [*]const Color) void {
        nk_style_from_table(self, colors);
    }

    pub fn styleLoadCursor(self: *Context, style: StyleCursor, cur: *const Cursor) void {
        nk_style_load_cursor(self, style, cur);
    }

    pub fn styleLoadAllCursors(self: *Context, cursors: [*]Cursor) void {
        nk_style_load_all_cursors(self, cursors);
    }

    pub fn styleSetFont(self: *Context, font: *const UserFont) void {
        nk_style_set_font(self, font);
    }

    pub fn styleSetCursor(self: *Context, style: StyleCursor) bool {
        return nk_style_set_cursor(self, style);
    }

    pub fn styleShowCursor(self: *Context) void {
        nk_style_show_cursor(self);
    }

    pub fn styleHideCursor(self: *Context) void {
        nk_style_hide_cursor(self);
    }

    pub fn stylePushFont(self: *Context, font: *const UserFont) bool {
        return nk_style_push_font(self, font);
    }

    pub fn stylePopFont(self: *Context) bool {
        return nk_style_pop_font(self);
    }

    extern fn nk_style_default(*Context) void;
    extern fn nk_style_from_table(*Context, [*]const Color) void;
    extern fn nk_style_load_cursor(*Context, StyleCursor, *const Cursor) void;
    extern fn nk_style_load_all_cursors(*Context, *Cursor) void;
    extern fn nk_style_get_color_by_name(StyleColors) [*:0]const u8;
    extern fn nk_style_set_font(*Context, *const UserFont) void;
    extern fn nk_style_set_cursor(*Context, StyleCursor) bool;
    extern fn nk_style_show_cursor(*Context) void;
    extern fn nk_style_hide_cursor(*Context) void;

    extern fn nk_style_push_font(*Context, *const UserFont) bool;
    extern fn nk_style_pop_font(*Context) bool;

    // not implemented ?
    extern fn nk_style_push_float(*Context, *f32, f32) bool;
    extern fn nk_style_push_vec2(*Context, *Vec2, Vec2) bool;
    extern fn nk_style_push_style_item(*Context, *StyleItem, StyleItem) bool;
    extern fn nk_style_push_flags(*Context, *Flags, Flags) bool;
    extern fn nk_style_push_color(*Context, *Color, Color) bool;
    extern fn nk_style_pop_float(*Context) bool;
    extern fn nk_style_pop_vec2(*Context) bool;
    extern fn nk_style_pop_style_item(*Context) bool;
    extern fn nk_style_pop_flags(*Context) bool;
    extern fn nk_style_pop_color(*Context) bool;
};

// ---- FontAtlas ----
pub const FontAtlas = extern struct {
    pixel: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    tex_width: c_int = @import("std").mem.zeroes(c_int),
    tex_height: c_int = @import("std").mem.zeroes(c_int),
    permanent: Allocator = @import("std").mem.zeroes(Allocator),
    temporary: Allocator = @import("std").mem.zeroes(Allocator),
    custom: RectI = @import("std").mem.zeroes(RectI),
    cursors: [7]Cursor = @import("std").mem.zeroes([7]Cursor),
    glyph_count: c_int = @import("std").mem.zeroes(c_int),
    glyphs: [*c]FontGlyph = @import("std").mem.zeroes([*c]FontGlyph),
    default_font: [*c]Font = @import("std").mem.zeroes([*c]Font),
    fonts: [*c]Font = @import("std").mem.zeroes([*c]Font),
    config: [*c]FontConfig = @import("std").mem.zeroes([*c]FontConfig),
    font_num: c_int = @import("std").mem.zeroes(c_int),

    pub const BakedData = struct {
        image: []const u8,
        width: u32,
        height: u32,
    };

    pub fn init(allocator: *const Allocator) FontAtlas {
        var ret: FontAtlas = undefined;
        nk_font_atlas_init(&ret, allocator);
        return ret;
    }

    pub fn begin(self: *FontAtlas) void {
        nk_font_atlas_begin(self);
    }

    pub fn end(self: *FontAtlas, texture: Handle, null_texture: ?*DrawNullTexture) void {
        nk_font_atlas_end(self, texture, null_texture);
    }

    pub fn addDefault(self: *FontAtlas, height: f32, config: ?*const FontConfig) *Font {
        return nk_font_atlas_add_default(self, height, config);
    }

    pub fn addFromMemory(self: *FontAtlas, data: []const u8, height: f32, config: ?*const FontConfig) *Font {
        return nk_font_atlas_add_from_memory(self, @ptrCast(data.ptr), data.len, height, config);
    }

    pub fn bake(self: *FontAtlas, format: FontAtlasFormat) BakedData {
        var w: c_int = 0;
        var h: c_int = 0;
        const img = nk_font_atlas_bake(self, &w, &h, format);

        const bytes_per_pixel: c_int = switch (format) {
            .rgba32 => 4,
            .alpha8 => 1,
        };

        const img_slice = @as([*]const u8, @ptrCast(img))[0..@intCast(w * h * bytes_per_pixel)];

        return .{
            .image = img_slice,
            .width = @intCast(w),
            .height = @intCast(h),
        };
    }

    pub fn clear(self: *FontAtlas) void {
        nk_font_atlas_clear(self);
    }

    extern fn nk_font_atlas_init(*FontAtlas, *Allocator) void;
    extern fn nk_font_atlas_init_custom(*FontAtlas, persistent: *Allocator, transient: *Allocator) void;
    extern fn nk_font_atlas_begin(*FontAtlas) void;
    extern fn nk_font_atlas_add(*FontAtlas, *const FontConfig) *Font;
    extern fn nk_font_atlas_add_default(*FontAtlas, height: f32, ?*const FontConfig) *Font;
    extern fn nk_font_atlas_add_from_memory(*FontAtlas, memory: *const anyopaque, size: usize, height: f32, config: ?*const FontConfig) *Font;
    extern fn nk_font_atlas_add_compressed(*FontAtlas, memory: *const anyopaque, size: usize, height: f32, ?*const FontConfig) *Font;
    extern fn nk_font_atlas_add_compressed_base85(*FontAtlas, data: [*:0]const u8, height: f32, config: ?*const FontConfig) *Font;
    extern fn nk_font_atlas_bake(*FontAtlas, width: *c_int, height: *c_int, FontAtlasFormat) *const anyopaque;
    extern fn nk_font_atlas_end(*FontAtlas, tex: Handle, ?*DrawNullTexture) void;
    extern fn nk_font_find_glyph(*Font, unicode: Rune) *const FontGlyph;
    extern fn nk_font_atlas_cleanup(*FontAtlas) void;
    extern fn nk_font_atlas_clear(*FontAtlas) void;
};

pub extern fn nk_font_config(pixel_height: f32) FontConfig;

pub extern fn nk_font_default_glyph_ranges() [*:0]const Rune;
pub extern fn nk_font_chinese_glyph_ranges() [*:0]const Rune;
pub extern fn nk_font_cyrillic_glyph_ranges() [*:0]const Rune;
pub extern fn nk_font_korean_glyph_ranges() [*:0]const Rune;

// ---- Buffer ----
pub const Buffer = extern struct {
    marker: [2]BufferMarker = @import("std").mem.zeroes([2]BufferMarker),
    pool: Allocator = @import("std").mem.zeroes(Allocator),
    type: AllocationType = @import("std").mem.zeroes(AllocationType),
    memory: Memory = @import("std").mem.zeroes(Memory),
    grow_factor: f32 = @import("std").mem.zeroes(f32),
    allocated: usize = @import("std").mem.zeroes(usize),
    needed: usize = @import("std").mem.zeroes(usize),
    calls: usize = @import("std").mem.zeroes(usize),
    size: usize = @import("std").mem.zeroes(usize),

    pub fn init(allocator: *const Allocator, size: usize) Buffer {
        var buf: Buffer = undefined;
        nk_buffer_init(&buf, allocator, size);
        return buf;
    }

    pub fn free(self: *Buffer) void {
        nk_buffer_free(self);
    }

    pub fn clear(self: *Buffer) void {
        nk_buffer_clear(self);
    }

    extern fn nk_buffer_init(*Buffer, *const Allocator, size: usize) void;
    extern fn nk_buffer_init_fixed(*Buffer, memory: *anyopaque, size: usize) void;
    extern fn nk_buffer_info(*MemoryStatus, *Buffer) void;
    extern fn nk_buffer_push(*Buffer, @"type": BufferAllocationType, memory: *const anyopaque, size: usize, @"align": usize) void;
    extern fn nk_buffer_mark(*Buffer, @"type": BufferAllocationType) void;
    extern fn nk_buffer_reset(*Buffer, @"type": BufferAllocationType) void;
    extern fn nk_buffer_clear(*Buffer) void;
    extern fn nk_buffer_free(*Buffer) void;
    extern fn nk_buffer_memory(*Buffer) *anyopaque;
    extern fn nk_buffer_memory_const(*const Buffer) *const anyopaque;
    extern fn nk_buffer_total(*Buffer) usize;
};

// ---- CommandBuffer ----
pub const CommandBuffer = extern struct {
    base: [*c]Buffer = @import("std").mem.zeroes([*c]Buffer),
    clip: Rect = @import("std").mem.zeroes(Rect),
    use_clipping: c_int = @import("std").mem.zeroes(c_int),
    userdata: Handle = @import("std").mem.zeroes(Handle),
    begin: usize = @import("std").mem.zeroes(usize),
    end: usize = @import("std").mem.zeroes(usize),
    last: usize = @import("std").mem.zeroes(usize),

    pub fn strokeLine(self: *CommandBuffer, x0: f32, y0: f32, x1: f32, y1: f32, line_thickness: f32, col: Color) void {
        nk_stroke_line(self, x0, y0, x1, y1, line_thickness, col);
    }

    pub fn strokeCurve(self: *CommandBuffer, x0: f32, y0: f32, cx0: f32, cy0: f32, cx1: f32, cy1: f32, x1: f32, y1: f32, line_thickness: f32, col: Color) void {
        nk_stroke_curve(self, x0, y0, cx0, cy0, cx1, cy1, x1, y1, line_thickness, col);
    }

    pub fn strokeRect(self: *CommandBuffer, rect: Rect, rounding: f32, line_thickness: f32, col: Color) void {
        nk_stroke_rect(self, rect, rounding, line_thickness, col);
    }

    pub fn strokeCircle(self: *CommandBuffer, rect: Rect, line_thickness: f32, col: Color) void {
        nk_stroke_circle(self, rect, line_thickness, col);
    }

    pub fn strokeArc(self: *CommandBuffer, cx: f32, cy: f32, radius: f32, a_min: f32, a_max: f32, line_thickness: f32, col: Color) void {
        nk_stroke_arc(self, cx, cy, radius, a_min, a_max, line_thickness, col);
    }

    pub fn strokeTriangle(self: *CommandBuffer, x0: f32, y0: f32, x1: f32, y1: f32, x2: f32, y2: f32, line_thichness: f32, col: Color) void {
        nk_stroke_triangle(self, x0, y0, x1, y1, x2, y2, line_thichness, col);
    }

    pub fn strokePolyline(self: *CommandBuffer, points: []f32, line_thickness: f32, col: Color) void {
        nk_stroke_polyline(self, points.ptr, @intCast(points.len), line_thickness, col);
    }

    pub fn strokePolygon(self: *CommandBuffer, points: []f32, line_thickness: f32, col: Color) void {
        nk_stroke_polygon(self, points.ptr, @intCast(points.len), line_thickness, col);
    }

    pub fn fillRect(self: *CommandBuffer, rect: Rect, rounding: f32, col: Color) void {
        nk_fill_rect(self, rect, rounding, col);
    }

    pub fn fillRectMultiColor(self: *CommandBuffer, rect: Rect, left: Color, top: Color, right: Color, bottom: Color) void {
        nk_fill_rect_multi_color(self, rect, left, top, right, bottom);
    }

    pub fn fillCircle(self: *CommandBuffer, rect: Rect, col: Color) void {
        nk_fill_circle(self, rect, col);
    }

    pub fn fillArc(self: *CommandBuffer, cx: f32, cy: f32, radius: f32, a_min: f32, a_max: f32, col: Color) void {
        nk_fill_arc(self, cx, cy, radius, a_min, a_max, col);
    }

    pub fn fillTriangle(self: *CommandBuffer, x0: f32, y0: f32, x1: f32, y1: f32, x2: f32, y2: f32, col: Color) void {
        nk_fill_triangle(self, x0, y0, x1, y1, x2, y2, col);
    }

    pub fn fillPolygon(self: *CommandBuffer, points: []f32, col: Color) void {
        nk_fill_polygon(self, points.ptr, @intCast(points.len), col);
    }

    pub fn drawImage(self: *CommandBuffer, rect: Rect, img: *const Image, col: Color) void {
        nk_draw_image(self, rect, img, col);
    }

    pub fn drawNineSlice(self: *CommandBuffer, rect: Rect, nine_slice: *const NineSlice, col: Color) void {
        nk_draw_nine_slice(self, rect, nine_slice, col);
    }

    pub fn drawText(self: *CommandBuffer, rect: Rect, text: []const u8, font: *const UserFont, bg: Color, fg: Color) void {
        nk_draw_text(self, rect, text.ptr, @intCast(text.len), font, bg, fg);
    }

    pub fn pushScissor(self: *CommandBuffer, rect: Rect) void {
        nk_push_scissor(self, rect);
    }

    pub fn pushCustom(self: *CommandBuffer, rect: Rect, callback: CommandCustomCallbackFn, usr: Handle) void {
        nk_push_custom(self, rect, callback, usr);
    }

    extern fn nk_stroke_line(*CommandBuffer, x0: f32, y0: f32, x1: f32, y1: f32, line_thickness: f32, Color) void;
    extern fn nk_stroke_curve(*CommandBuffer, f32, f32, f32, f32, f32, f32, f32, f32, line_thickness: f32, Color) void;
    extern fn nk_stroke_rect(*CommandBuffer, Rect, rounding: f32, line_thickness: f32, Color) void;
    extern fn nk_stroke_circle(*CommandBuffer, Rect, line_thickness: f32, Color) void;
    extern fn nk_stroke_arc(*CommandBuffer, cx: f32, cy: f32, radius: f32, a_min: f32, a_max: f32, line_thickness: f32, Color) void;
    extern fn nk_stroke_triangle(*CommandBuffer, f32, f32, f32, f32, f32, f32, line_thichness: f32, Color) void;
    extern fn nk_stroke_polyline(*CommandBuffer, points: [*]f32, point_count: c_int, line_thickness: f32, col: Color) void;
    extern fn nk_stroke_polygon(*CommandBuffer, [*]f32, point_count: c_int, line_thickness: f32, Color) void;
    extern fn nk_fill_rect(*CommandBuffer, Rect, rounding: f32, Color) void;
    extern fn nk_fill_rect_multi_color(*CommandBuffer, Rect, left: Color, top: Color, right: Color, bottom: Color) void;
    extern fn nk_fill_circle(*CommandBuffer, Rect, Color) void;
    extern fn nk_fill_arc(*CommandBuffer, cx: f32, cy: f32, radius: f32, a_min: f32, a_max: f32, Color) void;
    extern fn nk_fill_triangle(*CommandBuffer, x0: f32, y0: f32, x1: f32, y1: f32, x2: f32, y2: f32, Color) void;
    extern fn nk_fill_polygon(*CommandBuffer, [*]f32, point_count: c_int, Color) void;
    extern fn nk_draw_image(*CommandBuffer, Rect, *const Image, Color) void;
    extern fn nk_draw_nine_slice(*CommandBuffer, Rect, *const NineSlice, Color) void;
    extern fn nk_draw_text(*CommandBuffer, Rect, text: [*]const u8, len: c_int, *const UserFont, Color, Color) void;
    extern fn nk_push_scissor(*CommandBuffer, Rect) void;
    extern fn nk_push_custom(*CommandBuffer, Rect, CommandCustomCallbackFn, usr: Handle) void;
};

// ---- List View ----
pub const ListView = extern struct {
    begin: c_int = @import("std").mem.zeroes(c_int),
    end: c_int = @import("std").mem.zeroes(c_int),
    count: c_int = @import("std").mem.zeroes(c_int),
    total_height: c_int = @import("std").mem.zeroes(c_int),
    ctx: [*c]Context = @import("std").mem.zeroes([*c]Context),
    scroll_pointer: [*c]u32 = @import("std").mem.zeroes([*c]u32),
    scroll_value: u32 = @import("std").mem.zeroes(u32),

    pub fn end(self: *ListView) void {
        nk_list_view_end(self);
    }
    extern fn nk_list_view_end(*ListView) void;
};

// ---- Str ----
pub extern fn nk_str_init(*Str, *const Allocator, size: usize) void;
pub extern fn nk_str_init_fixed(*Str, memory: ?*anyopaque, size: usize) void;
pub extern fn nk_str_clear(*Str) void;
pub extern fn nk_str_free(*Str) void;
pub extern fn nk_str_append_text_char(*Str, [*]const u8, c_int) c_int;
pub extern fn nk_str_append_str_char(*Str, [*:0]const u8) c_int;
pub extern fn nk_str_append_text_utf8(*Str, [*]const u8, c_int) c_int;
pub extern fn nk_str_append_str_utf8(*Str, [*:0]const u8) c_int;
pub extern fn nk_str_append_text_runes(*Str, [*]const Rune, c_int) c_int;
pub extern fn nk_str_append_str_runes(*Str, [*:0]const Rune) c_int;
pub extern fn nk_str_insert_at_char(*Str, pos: c_int, [*]const u8, c_int) c_int;
pub extern fn nk_str_insert_at_rune(*Str, pos: c_int, [*]const u8, c_int) c_int;
pub extern fn nk_str_insert_text_char(*Str, pos: c_int, [*]const u8, c_int) c_int;
pub extern fn nk_str_insert_str_char(*Str, pos: c_int, [*:0]const u8) c_int;
pub extern fn nk_str_insert_text_utf8(*Str, pos: c_int, [*]const u8, c_int) c_int;
pub extern fn nk_str_insert_str_utf8(*Str, pos: c_int, [*:0]const u8) c_int;
pub extern fn nk_str_insert_text_runes(*Str, pos: c_int, [*]const Rune, c_int) c_int;
pub extern fn nk_str_insert_str_runes(*Str, pos: c_int, [*:0]const Rune) c_int;
pub extern fn nk_str_remove_chars(*Str, len: c_int) void;
pub extern fn nk_str_remove_runes(str: *Str, len: c_int) void;
pub extern fn nk_str_delete_chars(*Str, pos: c_int, len: c_int) void;
pub extern fn nk_str_delete_runes(*Str, pos: c_int, len: c_int) void;
pub extern fn nk_str_at_char(*Str, pos: c_int) [*]u8;
pub extern fn nk_str_at_rune(*Str, pos: c_int, unicode: [*c]Rune, len: *c_int) [*c]u8;
pub extern fn nk_str_rune_at(*const Str, pos: c_int) Rune;
pub extern fn nk_str_at_char_const(*const Str, pos: c_int) [*]const u8;
pub extern fn nk_str_at_const(*const Str, pos: c_int, unicode: [*c]Rune, len: *c_int) [*]const u8;
pub extern fn nk_str_get(*Str) [*]u8;
pub extern fn nk_str_get_const(*const Str) [*]const u8;
pub extern fn nk_str_len(*Str) c_int;
pub extern fn nk_str_len_char(*Str) c_int;

// ---- TextEdit ----
pub extern fn nk_textedit_init(*TextEdit, *Allocator, size: usize) void;
pub extern fn nk_textedit_init_fixed(*TextEdit, memory: *anyopaque, size: usize) void;
pub extern fn nk_textedit_free(*TextEdit) void;
pub extern fn nk_textedit_text(*TextEdit, [*]const u8, total_len: c_int) void;
pub extern fn nk_textedit_delete(*TextEdit, where: c_int, len: c_int) void;
pub extern fn nk_textedit_delete_selection(*TextEdit) void;
pub extern fn nk_textedit_select_all(*TextEdit) void;
pub extern fn nk_textedit_cut(*TextEdit) bool;
pub extern fn nk_textedit_paste(*TextEdit, [*]const u8, len: c_int) bool;
pub extern fn nk_textedit_undo(*TextEdit) void;
pub extern fn nk_textedit_redo(*TextEdit) void;

pub extern fn nk_filter_default(*const TextEdit, unicode: Rune) bool;
pub extern fn nk_filter_ascii(*const TextEdit, unicode: Rune) bool;
pub extern fn nk_filter_float(*const TextEdit, unicode: Rune) bool;
pub extern fn nk_filter_decimal(*const TextEdit, unicode: Rune) bool;
pub extern fn nk_filter_hex(*const TextEdit, unicode: Rune) bool;
pub extern fn nk_filter_oct(*const TextEdit, unicode: Rune) bool;
pub extern fn nk_filter_binary(*const TextEdit, unicode: Rune) bool;

// --- Input ---
pub extern fn nk_input_has_mouse_click(*const Input, Buttons) bool;
pub extern fn nk_input_has_mouse_click_in_rect(*const Input, Buttons, Rect) bool;
pub extern fn nk_input_has_mouse_click_in_button_rect(*const Input, Buttons, Rect) bool;
pub extern fn nk_input_has_mouse_click_down_in_rect(*const Input, Buttons, Rect, down: bool) bool;
pub extern fn nk_input_is_mouse_click_in_rect(*const Input, Buttons, Rect) bool;
pub extern fn nk_input_is_mouse_click_down_in_rect(*const Input, id: Buttons, b: Rect, down: bool) bool;
pub extern fn nk_input_any_mouse_click_in_rect(*const Input, Rect) bool;
pub extern fn nk_input_is_mouse_prev_hovering_rect(*const Input, Rect) bool;
pub extern fn nk_input_is_mouse_hovering_rect(*const Input, Rect) bool;
pub extern fn nk_input_mouse_clicked(*const Input, Buttons, Rect) bool;
pub extern fn nk_input_is_mouse_down(*const Input, Buttons) bool;
pub extern fn nk_input_is_mouse_pressed(*const Input, Buttons) bool;
pub extern fn nk_input_is_mouse_released(*const Input, Buttons) bool;
pub extern fn nk_input_is_key_pressed(*const Input, Keys) bool;
pub extern fn nk_input_is_key_released(*const Input, Keys) bool;
pub extern fn nk_input_is_key_down(*const Input, Keys) bool;

// ---- DrawList ----
pub extern fn nk_draw_list_init(*DrawList) void;
pub extern fn nk_draw_list_setup(*DrawList, *const ConvertConfig, cmds: *Buffer, vertices: *Buffer, elements: *Buffer, line_aa: AntiAliasing, shape_aa: AntiAliasing) void;
pub extern fn nk__draw_list_begin(*const DrawList, *const Buffer) ?*const DrawCommand;
pub extern fn nk__draw_list_next(*const DrawCommand, *const Buffer, *const DrawList) ?*const DrawCommand;
pub extern fn nk__draw_list_end(*const DrawList, *const Buffer) ?*const DrawCommand;
pub extern fn nk_draw_list_path_clear(*DrawList) void;
pub extern fn nk_draw_list_path_line_to(*DrawList, pos: Vec2) void;
pub extern fn nk_draw_list_path_arc_to_fast(*DrawList, center: Vec2, radius: f32, a_min: c_int, a_max: c_int) void;
pub extern fn nk_draw_list_path_arc_to(*DrawList, center: Vec2, radius: f32, a_min: f32, a_max: f32, segments: c_uint) void;
pub extern fn nk_draw_list_path_rect_to(*DrawList, a: Vec2, b: Vec2, rounding: f32) void;
pub extern fn nk_draw_list_path_curve_to(*DrawList, p2: Vec2, p3: Vec2, p4: Vec2, num_segments: c_uint) void;
pub extern fn nk_draw_list_path_fill(*DrawList, Color) void;
pub extern fn nk_draw_list_path_stroke(*DrawList, Color, closed: DrawListStroke, thickness: f32) void;
pub extern fn nk_draw_list_stroke_line(*DrawList, a: Vec2, b: Vec2, Color, thickness: f32) void;
pub extern fn nk_draw_list_stroke_rect(*DrawList, rect: Rect, Color, rounding: f32, thickness: f32) void;
pub extern fn nk_draw_list_stroke_triangle(*DrawList, a: Vec2, b: Vec2, c: Vec2, Color, thickness: f32) void;
pub extern fn nk_draw_list_stroke_circle(*DrawList, center: Vec2, radius: f32, Color, segs: c_uint, thickness: f32) void;
pub extern fn nk_draw_list_stroke_curve(*DrawList, p0: Vec2, cp0: Vec2, cp1: Vec2, p1: Vec2, Color, segments: c_uint, thickness: f32) void;
pub extern fn nk_draw_list_stroke_poly_line(*DrawList, pnts: [*]const Vec2, cnt: c_uint, Color, DrawListStroke, thickness: f32, AntiAliasing) void;
pub extern fn nk_draw_list_fill_rect(*DrawList, rect: Rect, Color, rounding: f32) void;
pub extern fn nk_draw_list_fill_rect_multi_color(*DrawList, rect: Rect, left: Color, top: Color, right: Color, bottom: Color) void;
pub extern fn nk_draw_list_fill_triangle(*DrawList, a: Vec2, b: Vec2, c: Vec2, Color) void;
pub extern fn nk_draw_list_fill_circle(*DrawList, center: Vec2, radius: f32, col: Color, segs: c_uint) void;
pub extern fn nk_draw_list_fill_poly_convex(*DrawList, points: [*]const Vec2, count: c_uint, Color, AntiAliasing) void;
pub extern fn nk_draw_list_add_image(*DrawList, texture: Image, rect: Rect, Color) void;
pub extern fn nk_draw_list_add_text(*DrawList, *const UserFont, Rect, text: [*]const u8, len: c_int, font_height: f32, Color) void;

// Useless?!

// pub extern fn nk_style_item_color(Color) StyleItem;
// pub extern fn nk_style_item_image(img: Image) StyleItem;
// pub extern fn nk_style_item_nine_slice(slice: NineSlice) StyleItem;
// pub extern fn nk_style_item_hide() StyleItem;

// pub extern fn nk_rgb_bv(rgb: [*c]const Byte) Color;
// pub extern fn nk_rgb_f(r: f32, g: f32, b: f32) Color;
// pub extern fn nk_rgb_fv(rgb: [*c]const f32) Color;
// pub extern fn nk_rgb_cf(c: ColorF) Color;
// pub extern fn nk_rgb_hex(rgb: [*c]const u8) Color;
// pub extern fn nk_rgba(r: c_int, g: c_int, b: c_int, a: c_int) Color;
// pub extern fn nk_rgba_u32(u32) Color;
// pub extern fn nk_rgba_iv(rgba: [*c]const c_int) Color;
// pub extern fn nk_rgba_bv(rgba: [*c]const Byte) Color;
// pub extern fn nk_rgba_f(r: f32, g: f32, b: f32, a: f32) Color;
// pub extern fn nk_rgba_fv(rgba: [*c]const f32) Color;
// pub extern fn nk_rgba_cf(c: ColorF) Color;
// pub extern fn nk_rgba_hex(rgb: [*c]const u8) Color;
// pub extern fn nk_hsva_colorf(h: f32, s: f32, v: f32, a: f32) ColorF;
// pub extern fn nk_hsva_colorfv(c: [*c]f32) ColorF;
// pub extern fn nk_colorf_hsva_f(out_h: [*c]f32, out_s: [*c]f32, out_v: [*c]f32, out_a: [*c]f32, in: ColorF) void;
// pub extern fn nk_colorf_hsva_fv(hsva: [*c]f32, in: ColorF) void;
// pub extern fn nk_hsv(h: c_int, s: c_int, v: c_int) Color;
// pub extern fn nk_hsv_iv(hsv: [*c]const c_int) Color;
// pub extern fn nk_hsv_bv(hsv: [*c]const Byte) Color;
// pub extern fn nk_hsv_f(h: f32, s: f32, v: f32) Color;
// pub extern fn nk_hsv_fv(hsv: [*c]const f32) Color;
// pub extern fn nk_hsva(h: c_int, s: c_int, v: c_int, a: c_int) Color;
// pub extern fn nk_hsva_iv(hsva: [*c]const c_int) Color;
// pub extern fn nk_hsva_bv(hsva: [*c]const Byte) Color;
// pub extern fn nk_hsva_f(h: f32, s: f32, v: f32, a: f32) Color;
// pub extern fn nk_hsva_fv(hsva: [*c]const f32) Color;
// pub extern fn nk_color_f(r: [*c]f32, g: [*c]f32, b: [*c]f32, a: [*c]f32, Color) void;
// pub extern fn nk_color_fv(rgba_out: [*c]f32, Color) void;
// pub extern fn nk_color_cf(Color) ColorF;
// pub extern fn nk_color_d(r: [*c]f64, g: [*c]f64, b: [*c]f64, a: [*c]f64, Color) void;
// pub extern fn nk_color_dv(rgba_out: [*c]f64, Color) void;
// pub extern fn nk_color_u32(Color) u32;
// pub extern fn nk_color_hex_rgba(output: [*c]u8, Color) void;
// pub extern fn nk_color_hex_rgb(output: [*c]u8, Color) void;
// pub extern fn nk_color_hsv_i(out_h: [*c]c_int, out_s: [*c]c_int, out_v: [*c]c_int, Color) void;
// pub extern fn nk_color_hsv_b(out_h: [*c]Byte, out_s: [*c]Byte, out_v: [*c]Byte, Color) void;
// pub extern fn nk_color_hsv_iv(hsv_out: [*c]c_int, Color) void;
// pub extern fn nk_color_hsv_bv(hsv_out: [*c]Byte, Color) void;
// pub extern fn nk_color_hsv_f(out_h: [*c]f32, out_s: [*c]f32, out_v: [*c]f32, Color) void;
// pub extern fn nk_color_hsv_fv(hsv_out: [*c]f32, Color) void;
// pub extern fn nk_color_hsva_i(h: [*c]c_int, s: [*c]c_int, v: [*c]c_int, a: [*c]c_int, Color) void;
// pub extern fn nk_color_hsva_b(h: [*c]Byte, s: [*c]Byte, v: [*c]Byte, a: [*c]Byte, Color) void;
// pub extern fn nk_color_hsva_iv(hsva_out: [*c]c_int, Color) void;
// pub extern fn nk_color_hsva_bv(hsva_out: [*c]Byte, Color) void;
// pub extern fn nk_color_hsva_f(out_h: [*c]f32, out_s: [*c]f32, out_v: [*c]f32, out_a: [*c]f32, Color) void;
// pub extern fn nk_color_hsva_fv(hsva_out: [*c]f32, Color) void;
// pub extern fn nk_handle_ptr(?*anyopaque) Handle;
// pub extern fn nk_handle_id(c_int) Handle;
// pub extern fn nk_image_handle(Handle) Image;
// pub extern fn nk_image_ptr(?*anyopaque) Image;
// pub extern fn nk_image_id(c_int) Image;
// pub extern fn nk_subimage_id(c_int, w: u16, h: u16, sub_region: Rect) Image;
// pub extern fn nk_subimage_handle(Handle, w: u16, h: u16, sub_region: Rect) Image;
// pub extern fn nk_nine_slice_handle(Handle, l: u16, t: u16, r: u16, b: u16) NineSlice;
// pub extern fn nk_nine_slice_ptr(?*anyopaque, l: u16, t: u16, r: u16, b: u16) NineSlice;
// pub extern fn nk_nine_slice_id(c_int, l: u16, t: u16, r: u16, b: u16) NineSlice;
// pub extern fn nk_nine_slice_is_sub9slice(img: [*c]const NineSlice) c_int;
// pub extern fn nk_sub9slice_ptr(?*anyopaque, w: u16, h: u16, sub_region: Rect, l: u16, t: u16, r: u16, b: u16) NineSlice;
// pub extern fn nk_sub9slice_id(c_int, w: u16, h: u16, sub_region: Rect, l: u16, t: u16, r: u16, b: u16) NineSlice;
// pub extern fn nk_sub9slice_handle(Handle, w: u16, h: u16, sub_region: Rect, l: u16, t: u16, r: u16, b: u16) NineSlice;
// pub extern fn nk_murmur_hash(key: ?*const anyopaque, len: c_int, seed: Hash) Hash;
// pub extern fn nk_triangle_from_direction(result: [*c]Vec2, r: Rect, pad_x: f32, pad_y: f32, Heading) void;
// pub extern fn nk_vec2(x: f32, y: f32) Vec2;
// pub extern fn nk_vec2i(x: c_int, y: c_int) Vec2;
// pub extern fn nk_vec2v(xy: [*c]const f32) Vec2;
// pub extern fn nk_vec2iv(xy: [*c]const c_int) Vec2;
// pub extern fn nk_get_null_rect() Rect;
// pub extern fn nk_rect(x: f32, y: f32, w: f32, h: f32) Rect;
// pub extern fn nk_recti(x: c_int, y: c_int, w: c_int, h: c_int) Rect;
// pub extern fn nk_recta(pos: Vec2, size: Vec2) Rect;
// pub extern fn nk_rectv(xywh: [*c]const f32) Rect;
// pub extern fn nk_rectiv(xywh: [*c]const c_int) Rect;
// pub extern fn nk_rect_pos(Rect) Vec2;
// pub extern fn nk_rect_size(Rect) Vec2;
// pub extern fn nk_strlen(str: [*c]const u8) c_int;
// pub extern fn nk_stricmp(s1: [*c]const u8, s2: [*c]const u8) c_int;
// pub extern fn nk_stricmpn(s1: [*c]const u8, s2: [*c]const u8, n: c_int) c_int;
// pub extern fn nk_strtoi(str: [*c]const u8, endptr: [*c][*c]const u8) c_int;
// pub extern fn nk_strtof(str: [*c]const u8, endptr: [*c][*c]const u8) f32;
// pub extern fn nk_strtod(str: [*c]const u8, endptr: [*c][*c]const u8) f64;
// pub extern fn nk_strfilter(text: [*c]const u8, regexp: [*c]const u8) c_int;
// pub extern fn nk_strmatch_fuzzy_string(str: [*c]const u8, pattern: [*c]const u8, out_score: [*c]c_int) c_int;
// pub extern fn nk_strmatch_fuzzy_text(txt: [*c]const u8, txt_len: c_int, pattern: [*c]const u8, out_score: [*c]c_int) c_int;
// pub extern fn nk_utf_decode([*c]const u8, [*c]Rune, c_int) c_int;
// pub extern fn nk_utf_encode(Rune, [*c]u8, c_int) c_int;
// pub extern fn nk_utf_len([*c]const u8, byte_len: c_int) c_int;
// pub extern fn nk_utf_at(buffer: [*c]const u8, length: c_int, index: c_int, unicode: [*c]Rune, len: [*c]c_int) [*c]const u8;
