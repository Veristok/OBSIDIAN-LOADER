--- -- - h-hell ohel heoo hl    
-- made b y samet
-- idk date 2024 somethnimng ol

local library = {
    theme = {
        ["Accent"] = Color3.fromRGB(53, 60, 108),
        ["Main"] = Color3.fromRGB(23, 28, 41),
        ["Inline"] = Color3.fromRGB(12, 16, 25),
        ["Element"] = Color3.fromRGB(23, 28, 41),
        ["Text"] = Color3.fromRGB(255,255,255),
        ["Text Inactive"] = Color3.fromRGB(188,188,188),
        ["Border"] = Color3.fromRGB(3,3,3),
    };

    tweening = true,
    tweening_style = "Quart",
    tweening_direction = "Out",
    tweening_speed = 0.2,

    font = "windows-xp-tahoma", -- windows-xp-tahoma, proggy-square, minecraftia, proggy-clean, proggy-tiny
    font_size = 12,

    folder_name = "biggggui",

    flags = {};

    -- ignore
    theme_objects = {},
    theme_map = {},
    connections = {},
    tabs = {},
    real_tabs = {},
    sections = {},
    rainbows = {},
    lerps = {},
    fades = {},
    holder = nil,
    dragging = false,
};

do 
    -- services
    local tween_service = game:GetService("TweenService");
    local http_service = game:GetService("HttpService");
    local user_input_service = game:GetService("UserInputService");
    local run_service = game:GetService("RunService");
    -- globals
    local rgb = Color3.fromRGB;
	local rgbkey = ColorSequenceKeypoint.new;
	local rgbseq = ColorSequence.new;
	local numkey = NumberSequenceKeypoint.new;
	local numseq = NumberSequence.new;
	local dim2 = UDim2.new;
	local dim = UDim.new;
	local vec2 = Vector2.new;
	local rect = Rect.new;

    library.__index = library;
    library.tabs.__index = library.tabs;
    library.sections.__index = library.sections;
    
    do
        local lib_holder = Instance.new("ScreenGui", game:GetService("CoreGui"))
        lib_holder.ZIndexBehavior = Enum.ZIndexBehavior.Global;
        lib_holder.Name = "biggggui";
        library.holder = lib_holder;
    end;

    do -- folders
        if not isfolder(library.folder_name) then
            makefolder(library.folder_name);
        end;

        if not isfolder(library.folder_name .. "/images") then
            makefolder(library.folder_name .. "/images");
        end;

        if not isfolder(library.folder_name .. "/fonts") then
            makefolder(library.folder_name .. "/fonts");
        end;
    end;

    local library_folder = library.folder_name;
    local images_folder = library_folder .. "/images";
    local fonts_folder = library_folder .. "/fonts";

    local fonts = {};
    do -- custom font
        fonts = {
            ["windows-xp-tahoma"] = {
                file_name = {"windowsXPTahoma.ttf", "windowsXPTahoma.json"},
                url = "https://raw.githubusercontent.com/sametexe001/luas/main/fonts/windows-xp-tahoma.ttf"
            };

            ["proggy-square"] = {
                file_name = {"proggySquare.ttf", "proggySquare.json"},
                url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/proggy-square.ttf"
            };

            ["proggy-clean"] = {
                file_name = {"proggyClean.ttf", "proggySquare.json"},
                url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/proggy-clean.ttf"
            };

            ["proggy-tiny"] = {
                file_name = {"proggyTiny.ttf", "proggyTiny.json"},
                url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/proggy-tiny.ttf"
            };

            ["minecraftia"] = {
                file_name = {"minecraftia.ttf", "minecraftia.json"},
                url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/minecraftia.ttf"
            };
        };

        for font_name, font_data in fonts do
            if not isfile(fonts_folder .. "/" .. font_data.file_name[1]) then
                writefile(fonts_folder .. "/" .. font_data.file_name[1], game:HttpGet(font_data.url));
            end;

            local data = {
                name = font_name,
                faces = {{
                    name = "Regular",
                    weight = 200,
                    style = "Regular",
                    assetId = getcustomasset(fonts_folder .. "/" .. font_data.file_name[1]);
                }};
            };

            if not isfile(fonts_folder .. "/" .. font_data.file_name[2]) then
                writefile(fonts_folder .. "/" .. font_data.file_name[2], http_service:JSONEncode(data));
            end;
        end;

        fonts.get_font_from_name = function(font_name)
            for name, data in fonts do
                if name == font_name then -- the naming is weird ik
                    return Font.new(getcustomasset(fonts_folder .. "/" .. data.file_name[2]))
                end;
            end;
        end;
    end;

    local lib_font = fonts.get_font_from_name(library.font);

    local utility = {}; do
        utility.tween = function(object, data)
            local tween = tween_service:Create(object, TweenInfo.new(library.tweening_speed, Enum.EasingStyle[library.tweening_style], Enum.EasingDirection[library.tweening_direction]), data);
            tween:Play();
            return tween;
        end;

        utility.lerp = function(start, stop, t)
            return start + (stop - start) * t;
        end;

        utility.round = function(number, float)
            local multiplier = 1 / (float or 1);
            return math.floor(number * multiplier + 0.5) / multiplier;
        end;

        utility.add_to_theme = function(instance, properties)
            local instance_data = {
                instance = instance,
                data = properties,
                index = #library.theme_objects + 1
            };

            for index, value in properties do
                if type(value) == "string" then
                    if library.tweening then
                        instance_data.tween = utility.tween(instance, { [index] = library.theme[value] });
                    else
                        instance_data.instance[index] = library.theme[value];
                    end;
                else
                    instance_data.instance[index] = value();
                end;
            end;
            
            table.insert(library.theme_objects, instance_data);
            library.theme_map[instance] = instance_data;
        end;
        

        utility.change_object_theme = function(instance, properties)
            local is_obj = library.theme_map[instance];

            if is_obj then
                local obj_data = is_obj.data;

                for index, value in properties do
                    if type(value) == "string" then
                        obj_data[index] = library.theme[value];
                    else
                        obj_data[index] = value();
                    end;
                end;
            end;
        end;

        utility.change_theme = function(theme, color)
            for obj, value in library.theme_map do
                local obj_properties = value.Properties;
    
                for property, property_theme in obj_properties do
                    if property_theme == theme then
                        if value.tween then
                            value.tween:Cancel();
                        end;
    
                        obj[property] = color;
                    end;
                end;
            end;
        end;

        utility.new = function(class, properties)
            local object = Instance.new(class);

            for property, value in properties do
                object[property] = value;
            end;

            return object;
        end;

        utility.connect = function(signal, func, name)
            local connection = signal:Connect(func);

            if not library.connections[name] then
                library.connections[name] = {
                    signal = connection,
                    func = func,
                    name = name,
                };
            end;

            return connection;
        end;

        utility.disconnect = function(name)
            local is_con = library.connections[name];

            if not is_con then 
                return;
            end;

            is_con.signal:Disconnect();
            is_con = nil;
        end;

        utility.next_flag = function()
            local NextFlag = #library.flags + 1; 
            return string.format("Flag %s", math.random(0, NextFlag) * 2);
        end;

        utility.new_tab = function(iswindowtab, parent, content_parent, contentsizex, contentsizey, contentposx, contentposy, table_to_stack, real_table_to_stack, text)
            local tab = {
                name = text,
                active = false,
                hovered = false,
                objects = {};
            };
            local objects = {};

            objects["inactive"] = utility.new("Frame", {
                Parent = parent,
                Name = "inactive",
                BorderColor3 = library.theme.Border,
                BorderSizePixel = 0;
                Size = dim2(0, 52, 0, 18),
                BackgroundColor3 = library.theme.Inline
            })

            utility.add_to_theme(objects["inactive"],  {
                BorderColor3 = "Border",
                BackgroundColor3 = "Inline"
            });
            
            objects["TextButton"] = utility.new("TextButton", {
                Parent = objects["inactive"],
                FontFace = lib_font,
                TextColor3 = library.theme["Text Inactive"],
                BorderColor3 = rgb(0, 0, 0),
                Text = tab.name,
                BackgroundTransparency = 1,
                Position = dim2(0, 1, 0, 0),
                Size = dim2(1, 0, 1, 0),
                BorderSizePixel = 0,
                TextSize = library.font_size,
                BackgroundColor3 = rgb(255, 255, 255)
            })

            utility.add_to_theme(objects["TextButton"], {
                TextColor3 = "Text Inactive",
            })
            
            objects["UIStroke"] = utility.new("UIStroke", {
                Parent = objects["TextButton"],
                LineJoinMode = Enum.LineJoinMode.Miter,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
            });

            objects["TabContent"] = utility.new("Frame", {
                Parent = content_parent,
                Name = tab.name,
                BackgroundTransparency = 1,
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(0, contentsizex, 0, contentsizey),
                Position = dim2(0, contentposx, 0, contentposy),
                Visible = false,
            })

            if iswindowtab == true then
                objects["section_holders"] = utility.new("ScrollingFrame", {
                    Parent = objects["TabContent"],
                    ScrollBarImageColor3 = rgb(0, 0, 0),
                    Active = true,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 0,
                    Name = "section_holders",
                    BackgroundTransparency = 1,
                    Size = dim2(1, 0, 1, 0),
                    BackgroundColor3 = rgb(255, 255, 255),
                    BorderColor3 = rgb(0, 0, 0),
                    BorderSizePixel = 0,
                    CanvasSize = dim2(0, 0, 0, 0)
                })
                
                objects["left"] = utility.new("Frame", {
                    Parent = objects["section_holders"],
                    Name = "left",
                    BackgroundTransparency = 1,
                    Position = dim2(0, 2, 0, 2),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(0.4909999966621399, 0, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 255, 255)
                })
                
                objects["UIListLayout"] = utility.new("UIListLayout", {
                    Parent = objects["left"],
                    Padding = dim(0, 7),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                objects["right"] = utility.new("Frame", {
                    Parent = objects["section_holders"],
                    BorderColor3 = rgb(0, 0, 0),
                    AnchorPoint = vec2(1, 0),
                    BackgroundTransparency = 1,
                    Position = dim2(1, 0, 0, 0),
                    Name = "right",
                    Size = dim2(0.4909999966621399, 0, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 255, 255)
                })
                
                objects["UIListLayout2"] = utility.new("UIListLayout", {
                    Parent = objects["right"],
                    Padding = dim(0, 7),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            end;

            function tab:switch(bool)
                tab.active = bool;
                objects["TabContent"].Visible = bool;

                if bool then
                    objects["inactive"].BorderSizePixel = 0
                    if library.tweening then
                        utility.tween(objects["TextButton"], {TextColor3 = library.theme["Text"]});
                        utility.tween(objects["inactive"], {BackgroundColor3 = library.theme.Main});      
                    else
                        objects["inactive"].BackgroundColor3 = library.theme.Main;
                        objects["TextButton"].TextColor3 = library.theme["Text"];                  
                    end;

                    utility.change_object_theme(objects["TextButton"], {TextColor3 = "Text"});
                    utility.change_object_theme(objects["inactive"], {BackgroundColor3 = "Main"});
                else
                    objects["inactive"].BorderSizePixel = 1
                    if library.tweening then
                        utility.tween(objects["TextButton"], {TextColor3 = library.theme["Text Inactive"]});
                        utility.tween(objects["inactive"], {BackgroundColor3 = library.theme.Inline});      
                    else
                        objects["inactive"].BackgroundColor3 = library.theme.Inline;
                        objects["TextButton"].TextColor3 = library.theme["Text Inactive"];                  
                    end;

                    utility.change_object_theme(objects["TextButton"], {TextColor3 = "Text Inactive"});
                    utility.change_object_theme(objects["inactive"], {BackgroundColor3 = "Inline"});
                end;
            end;

            utility.connect(objects["TextButton"].MouseButton1Down, function()
                for _, new_tab in table_to_stack do
                    new_tab:switch(new_tab == tab);
                end;
            end, tab.name .. "switchEvent")

            if iswindowtab then
                tab.objects = {
                    main = objects["section_holders"];
                    left = objects["left"];
                    right = objects["right"];
                };
            else
                tab.objects = {
                    content = objects["TabContent"];
                };
            end;

            table.insert(table_to_stack, tab);
            return setmetatable(tab, real_table_to_stack), objects;
        end;
    end;

    utility.new_toggle = function(parent, size, position, data)
        assert(data.flag, "Missing flag");

        local toggle = {
            value = false;
        };
        local objects = {};
        objects["toggle"] = utility.new("TextButton", {
            Parent = parent,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = rgb(0, 0, 0),
            BorderColor3 = rgb(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Name = data.name,
            Size = dim2(size.X.Scale, size.X.Offset, size.Y.Scale, size.Y.Offset),
            BorderSizePixel = 0,
            TextSize = 14,
            Position = dim2(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset),
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        objects["indicator"] = utility.new("Frame", {
            Parent = objects["toggle"],
            Name = "indicator",
            Position = dim2(0, 0, 0, 2),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 10, 0, 10),
            BorderSizePixel = 0,
            BackgroundColor3 = library.theme.Element
        })

        utility.add_to_theme(objects["indicator"], {
            BackgroundColor3 = "Element"
        })
        
        objects["UIStroke"] = utility.new("UIStroke", {
            Parent = objects["indicator"],
            Color = library.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        
        utility.add_to_theme(objects["UIStroke"], {
            Color = "Border"
        })

        objects["gradient"] = utility.new("UIGradient", {
            Parent = objects["indicator"],
            Rotation = 90,
            Name = "gradient",
            Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(132, 132, 132))}
        })
        
        objects["text"] = utility.new("TextLabel", {
            Parent = objects["toggle"],
            FontFace = lib_font,
            TextColor3 = library.theme.Text,
            BorderColor3 = rgb(0, 0, 0),
            Text = data.name,
            Name = "text",
            Size = dim2(1, 0, 0, 12),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = dim2(0, 15, 0, 0),
            BorderSizePixel = 0,
            TextSize = library.font_size,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        utility.add_to_theme(objects["text"], {
            TextColor3 = "Text"
        })
        
        objects["UIStroke2"] = utility.new("UIStroke", {
            Parent = objects["text"],
            Color = rgb(0, 0, 0),
            LineJoinMode = Enum.LineJoinMode.Miter
        })

        function toggle:set(value)
            toggle.value = value;
            if value then
                if library.tweening then
                    utility.tween(objects["indicator"], {BackgroundColor3 = library.theme.Accent});
                else
                    objects["indicator"].BackgroundColor3 = library.theme.Accent;
                end;
                utility.change_object_theme(objects["indicator"], {BackgroundColor3 = "Accent"});
            else
                if library.tweening then
                    utility.tween(objects["indicator"], {BackgroundColor3 = library.theme.Element});
                else
                    objects["indicator"].BackgroundColor3 = library.theme.Element;
                end;
                utility.change_object_theme(objects["indicator"], {BackgroundColor3 = "Element"});
            end;

            if data.callback then
                data.callback(toggle.value);
            end;
        end;

        function toggle:get()
            return toggle.value;
        end;

        utility.connect(objects["toggle"].MouseButton1Down, function()
            toggle:set(not toggle.value);
        end, data.name .. "_pressEvent");

        if data.default then
            toggle:set(data.default);
        end;

        library.flags[data.flag] = toggle;
        return toggle, objects;
    end;

    utility.new_button = function(parent, size, position, data)
        assert(data.callback, "Missing callback");
        local button = {};
        local objects = {};

        objects["button"] = utility.new("TextButton", {
            Parent = parent,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = rgb(0, 0, 0),
            BorderColor3 = rgb(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            Name = data.name,
            Size = dim2(size.X.Scale, size.X.Offset, size.Y.Scale, size.Y.Offset),
            Position = dim2(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset),
            BorderSizePixel = 0,
            TextSize = 14,
            BackgroundColor3 = library.theme.Element
        })

        utility.add_to_theme(objects["button"], {
            BackgroundColor3 = "Element"
        })
        
        objects["gradient"] = utility.new("UIGradient", {
            Parent = objects["button"],
            Rotation = 90,
            Name = "gradient",
            Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(132, 132, 132))}
        })
        
        objects["UIStroke1"] = utility.new("UIStroke", {
            Parent = objects["button"],
            Color = library.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

        utility.add_to_theme(objects["UIStroke1"], {
            Color = "Border"
        })
        
        objects["text"] = utility.new("TextLabel", {
            Parent = objects["button"],
            FontFace = lib_font,
            TextColor3 = library.theme.Text,
            BorderColor3 = rgb(0, 0, 0),
            Text = data.name,
            BackgroundTransparency = 1,
            Name = "text",
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextSize = library.font_size,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        utility.add_to_theme(objects["text"], {
            TextColor3 = "Text"
        })
        
        objects["UIStroke2"] = utility.new("UIStroke", {
            Parent = objects["text"],
            Color = rgb(0, 0, 0),
            LineJoinMode = Enum.LineJoinMode.Miter
        });

        utility.connect(objects["button"].MouseButton1Down, function()
            data.callback();
            if library.tweening then
                utility.tween(objects["text"], {TextColor3 = library.theme.Accent});
            else
                objects["text"].TextColor3 = library.theme.Accent;
            end;
            utility.change_object_theme(objects["text"], {TextColor3 = "Accent"});
            task.wait(0.1);
            if library.tweening then
                utility.tween(objects["text"], {TextColor3 = library.theme.Text});
            else
                objects["text"].TextColor3 = library.theme.Text;
            end;
            utility.change_object_theme(objects["text"], {TextColor3 = "Text"});
        end, data.name .. "_clickEvent");

        return button, objects;
    end;

    utility.new_slider = function(parent, size, position, data)
        local objects = {};
        local slider = {
            value = 0;
            sliding = false;
        };

        objects["slider"] = utility.new("Frame", {
            Parent = parent,
            BackgroundTransparency = 1,
            Name = "slider",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(size.X.Scale, size.X.Offset, size.Y.Scale, size.Y.Offset),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255),
            Position = dim2(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset)
        })
        
        objects["text"] = utility.new("TextLabel", {
            Parent = objects["slider"],
            FontFace = lib_font,
            TextColor3 = library.theme.Text,
            BorderColor3 = rgb(0, 0, 0),
            Text = data.name,
            Name = "text",
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = dim2(1, 0, 0, 14),
            BorderSizePixel = 0,
            TextSize = library.font_size,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        if data.compact then
            objects["text"]:Destroy();
            objects["slider"].Size = dim2(size.X.Scale, size.X.Offset, size.Y.Scale, 12);
        end;

        utility.add_to_theme(objects["text"], {TextColor3 = "Text"});
        
        objects["UIStroke"] = utility.new("UIStroke", {
            Parent = objects["text"],
            Color = rgb(0, 0, 0),
            LineJoinMode = Enum.LineJoinMode.Miter
        })
        
        objects["real_slider"] = utility.new("Frame", {
            Parent = objects["slider"],
            AnchorPoint = vec2(0, 1),
            Name = "real_slider",
            Position = dim2(0, 0, 1, 0),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 0, 12),
            BorderSizePixel = 0,
            BackgroundColor3 = library.theme.Element
        })

        utility.add_to_theme(objects["real_slider"], {BackgroundColor3 = "Element"})
        
        objects["UIStroke2"] = utility.new("UIStroke", {
            Parent = objects["real_slider"],
            Color = library.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

        utility.add_to_theme(objects["UIStroke2"], {Color = "Border"})
        
        objects["gradient"] = utility.new("UIGradient", {
            Parent = objects["real_slider"],
            Rotation = 90,
            Name = "gradient",
            Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(132, 132, 132))}
        })
        
        objects["indicator"] = utility.new("Frame", {
            Parent = objects["real_slider"],
            Name = "indicator",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0.10000000149011612, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = library.theme.Accent
        })

        utility.add_to_theme(objects["indicator"], {BackgroundColor3 = "Accent"});
        
        objects["gradient"] = utility.new("UIGradient", {
            Parent = objects["indicator"],
            Rotation = 90,
            Name = "gradient",
            Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(132, 132, 132))}
        })
        
        objects["value"] = utility.new("TextLabel", {
            Parent = objects["real_slider"],
            FontFace = lib_font,
            TextColor3 = library.theme.Text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "0.1/1s",
            BackgroundTransparency = 1,
            Name = "value",
            Size = dim2(1, 0, 1, -1),
            BorderSizePixel = 0,
            TextSize = library.font_size,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        utility.add_to_theme(objects["value"], {TextColor3 = "Text"});
        
        objects["UIStroke3"] = utility.new("UIStroke", {
            Parent = objects["value"],
            Color = rgb(0, 0, 0),
            LineJoinMode = Enum.LineJoinMode.Miter
        })

        function slider:set(value)
            slider.value = math.clamp(utility.round(value, data.decimals), data.min, data.max);
            
            if not data.compact then
                objects["value"].Text = string.format("%s%s", tostring(slider.value) .. "/" .. tostring(data.max), data.suffix);
            else
                objects["value"].Text = string.format("%s: %s%s", data.name, tostring(slider.value) .. "/" .. tostring(data.max), data.suffix);
            end;

            if library.tweening then
                tween_service:Create(objects["indicator"], TweenInfo.new(0.09, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),{Size = dim2((slider.value - data.min) / (data.max - data.min), 0, 1, 0)}):Play();
            else
                objects["indicator"].Size = dim2((slider.value - data.min) / (data.max - data.min), 0, 1, 0);
            end;

            if data.infinite and slider.value == data.max then
                objects["value"].Text = "Infinite";
            else
                objects["value"].Text = string.format("%s%s", tostring(slider.value) .. "/" .. tostring(data.max), data.suffix);
            end;

            if data.callback then
                data.callback(slider.value);
            end;
        end;

        function slider:get()
            return slider.value;
        end;

        utility.connect(objects["real_slider"].InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                slider.sliding = true;
                local size_x = (input.Position.X - objects["real_slider"].AbsolutePosition.X) / objects["real_slider"].AbsoluteSize.X;
                local value = ((data.max - data.min) * size_x) + data.min;
                slider:set(value);
            end;
        end, data.name .. "real_sliderInputBegan");

        utility.connect(objects["real_slider"].InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                slider.sliding = false;
            end;
        end, data.name .. "real_sliderInputEnded");

        utility.connect(user_input_service.InputChanged, function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                if slider.sliding then
                    local size_x = (input.Position.X - objects["real_slider"].AbsolutePosition.X) / objects["real_slider"].AbsoluteSize.X;
                    local value = ((data.max - data.min) * size_x) + data.min;
                    slider:set(value);
                    library.dragging = nil;
                end;
            end;
        end, data.name .. "inputChanged_");

        slider:set(data.default);

        library.flags[data.flag] = slider;
        return slider, objects;
    end;

    function utility.new_dropdown(parent, size, position, data)
        local dropdown = {
            open = false,
            value = data.multi and {} or nil,
            options = {};
        };
        local objects = {};

        objects["dropdown"] = utility.new("Frame", {
            Parent = parent,
            BackgroundTransparency = 1,
            Name = "dropdown",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(size.X.Scale, size.X.Offset, size.Y.Scale, size.Y.Offset),
            BorderSizePixel = 0,
            Position = dim2(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset),
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        objects["text"] = utility.new("TextLabel", {
            Parent = objects["dropdown"],
            FontFace = lib_font,
            TextColor3 = library.theme.Text,
            BorderColor3 = rgb(0, 0, 0),
            Text = data.name,
            Name = "text",
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = dim2(1, 0, 0, 14),
            BorderSizePixel = 0,
            TextSize = library.font_size,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        utility.add_to_theme(objects["text"], {TextColor3 = "Text"});

        objects["UIStroke"] = utility.new("UIStroke", {
            Parent = objects["text"],
            Color = rgb(0, 0, 0),
            LineJoinMode = Enum.LineJoinMode.Miter
        })
        
        objects["real_dropdown"] = utility.new("Frame", {
            Parent = objects["dropdown"],
            AnchorPoint = vec2(0, 1),
            Name = "real_dropdown",
            Position = dim2(0, 0, 1, 0),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 0, 15),
            BorderSizePixel = 0,
            BackgroundColor3 = library.theme.Element
        })

        utility.add_to_theme(objects["real_dropdown"], {BackgroundColor3 = "Element"});
        
        objects["UIStroke2"] = utility.new("UIStroke", {
            Parent = objects["real_dropdown"],
            Color = library.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

        utility.add_to_theme(objects["UIStroke2"], {Color = "Border"});
        
        objects["gradient"] = utility.new("UIGradient", {
            Parent = objects["real_dropdown"],
            Rotation = 90,
            Name = "gradient",
            Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(132, 132, 132))}
        })
        
        objects["value"] = utility.new("TextLabel", {
            Parent = objects["real_dropdown"],
            FontFace = lib_font,
            TextColor3 = library.theme.Text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "--",
            Name = "value",
            Size = dim2(1, 0, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = dim2(0, 4, 0, -1),
            BorderSizePixel = 0,
            TextSize = library.font_size,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        utility.add_to_theme(objects["value"], {TextColor3 = "Text"});
        
        objects["UIStroke3"] = utility.new("UIStroke", {
            Parent = objects["value"],
            Color = rgb(0, 0, 0),
            LineJoinMode = Enum.LineJoinMode.Miter
        })
        
        objects["open"] = utility.new("TextButton", {
            Parent = objects["real_dropdown"],
            FontFace = lib_font,
            TextColor3 = library.theme.Text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "+",
            AutoButtonColor = false,
            Name = "open",
            Size = dim2(1, -5, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Right,
            Position = dim2(0, 0, 0, -1),
            BorderSizePixel = 0,
            TextSize = library.font_size,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        utility.add_to_theme(objects["open"], {TextColor3 = "Text"});
        
        objects["UIStroke4"] = utility.new("UIStroke", {
            Parent = objects["open"],
            Color = rgb(0, 0, 0),
            LineJoinMode = Enum.LineJoinMode.Miter
        })
        
        objects["option_holder"] = utility.new("Frame", {
            Parent = objects["dropdown"],
            Visible = false,
            BorderColor3 = rgb(0, 0, 0),
            Name = "option_holder",
            Position = dim2(0, 0, 1, 3),
            Size = dim2(1, 0, 0, 15),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = library.theme.Inline
        })

        utility.add_to_theme(objects["option_holder"], {BackgroundColor3 = "Inline"});
        
        objects["UIStroke5"] = utility.new("UIStroke", {
            Parent = objects["option_holder"],
            Color = rgb(3, 3, 3),
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

        utility.add_to_theme(objects["UIStroke5"], {Color = "Border"});
        
        objects["UIListLayout"] = utility.new("UIListLayout", {
            Parent = objects["option_holder"],
            Padding = dim(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        function dropdown:set_open(bool)
            self.open = bool;
            
            for _, instance in objects["dropdown"]:GetDescendants() do
                if not instance.ClassName:find("UI") then
                    instance.ZIndex = bool and 15 or 1;
                end;
            end;
            
            objects["option_holder"].Visible = bool
            objects["open"].Text = bool and "-" or "+";
        end;

        function dropdown:set(option)
            if not data.multi then
                if dropdown.options[option] then
                    local option_objects = dropdown.options[option];
                    option_objects.is_selected = true;

                    if library.tweening then
                        utility.tween(option_objects.text, {TextColor3 = library.theme.Accent});
                    else
                        option_objects.text.TextColor3 = library.theme.Accent;
                    end;

                    objects["value"].Text = option_objects.is_selected and tostring(option_objects.name) or "--";

                    utility.change_object_theme(option_objects.text, {TextColor3 = "Accent"});

                    for index, value in dropdown.options do
                        if value ~= option_objects then
                            value.is_selected = false;

                            if library.tweening then
                                utility.tween(value.text, {TextColor3 = library.theme.Text});
                            else
                                value.text.TextColor3 = library.theme.Text;
                            end;

                            utility.change_object_theme(value.text, {TextColor3 = "Text"});
                        end;
                    end;
                end;
            else
                for _, opt_name in option do
                    local table_index = dropdown.options[opt_name];

                    if table_index then
                        table_index.is_selected = true;
                        if library.tweening then
                            utility.tween(table_index.text, {TextColor3 = library.theme.Accent});
                        else
                            table_index.text.TextColor3 = library.theme.Accent;
                        end;
                        objects["value"].Text = table.concat(option, ", ") or "--";
                        utility.change_object_theme(table_index.text, {TextColor3 = "Accent"});
                    end;
                end;
            end;

            if data.callback then
                data.callback(dropdown.value);
            end;
        end;

        utility.connect(objects["open"].MouseButton1Down, function()
            dropdown:set_open(not dropdown.open);
        end, data.name .. "_openEvent");

        function dropdown:add_option(option)
            local sub_objects = {};
            sub_objects["option"] = utility.new("TextButton", {
                Parent = objects["option_holder"],
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                TextColor3 = rgb(0, 0, 0),
                BorderColor3 = rgb(0, 0, 0),
                Text = "",
                BackgroundTransparency = 1,
                Name = option,
                Size = dim2(1, 0, 0, 17),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundColor3 = rgb(255, 255, 255)
            })
            
            sub_objects["value"] = utility.new("TextLabel", {
                Parent = sub_objects["option"],
                FontFace = lib_font,
                TextColor3 = library.theme.Text,
                BorderColor3 = rgb(0, 0, 0),
                Text = option,
                Name = "value",
                Size = dim2(1, 0, 1, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = dim2(0, 4, 0, -1),
                BorderSizePixel = 0,
                TextSize = library.font_size,
                BackgroundColor3 = rgb(255, 255, 255)
            })

            utility.add_to_theme(sub_objects["value"], {TextColor3 = "Text"});
            
            sub_objects["UIStroke"] = utility.new("UIStroke", {
                Parent = sub_objects["value"],
                Color = rgb(0, 0, 0),
                LineJoinMode = Enum.LineJoinMode.Miter
            })

            local new_option = {
                name = option;
                object = sub_objects["option"];
                text = sub_objects["value"];
                is_selected = false;
            };

            function new_option:set(status)
                new_option.is_selected = status;

                if not data.multi then -- this is so ugly sry
                    if status then
                        dropdown.value = new_option;

                        if library.tweening then
                            utility.tween(new_option.text, {TextColor3 = library.theme.Accent});
                        else
                            new_option.text.TextColor3 = library.theme.Accent;
                        end;

                        utility.change_object_theme(new_option.text, {TextColor3 = "Accent"});

                        for index, value in dropdown.options do
                            if value ~= new_option then
                                value.is_selected = false;

                                if library.tweening then
                                    utility.tween(value.text, {TextColor3 = library.theme.Text});
                                else
                                    value.text.TextColor3 = library.theme.Text;
                                end;
                                
                                utility.change_object_theme(value.text, {TextColor3 = "Text"});
                            end;
                        end;
                    else
                        dropdown.value = nil;

                        if library.tweening then
                            utility.tween(new_option.text, {TextColor3 = library.theme.Text});
                        else
                            new_option.text.TextColor3 = library.theme.Text;
                        end;

                        utility.change_object_theme(new_option.text, {TextColor3 = "Text"});
                    end;

                    objects["value"].Text = new_option.is_selected and tostring(new_option.name) or "--";
                else
                    local index = table.find(dropdown.value, new_option.name);

                    if index then
                        table.remove(dropdown.value, index);
                        new_option.is_selected = false;
                    else
                        table.insert(dropdown.value, new_option.name);
                        new_option.is_selected = true;
                    end;

                    objects["value"].Text = table.concat(dropdown.value, ", ");

                    if library.tweening then
                        utility.tween(new_option.text, {TextColor3 = index and library.theme.Text or library.theme.Accent});
                    else
                        new_option.text.TextColor3 = index and library.theme.Text or library.theme.Accent;
                    end;

                    utility.change_object_theme(new_option.text, {TextColor3 = index and "Text" or "Accent"});
                end;

                if data.callback then
                    data.callback(dropdown.value);
                end;
            end;

            utility.connect(new_option.object.MouseButton1Down, function()
                new_option:set(not new_option.is_selected);
            end, new_option.name .. "clickEvent");

            self.options[new_option.name] = new_option
        end;

        for _, option in data.options do
            dropdown:add_option(option);
        end;

        if data.default then
            dropdown:set(data.default);
        end;

        library.flags[data.flag] = dropdown;
        return dropdown, objects;
    end;

    
    utility.new_listbox = function(parent, size, position, data)
        local objects = {};
        local listbox = {
            open = false,
            value = nil;
            options = {};
        };
        objects["Listbox"] = utility.new("Frame", {
            Parent = parent,
            BorderColor3 = rgb(0, 0, 0),
            AnchorPoint = vec2(0, 1),
            BackgroundTransparency = 1,
            Name = data.name,
            Size = dim2(size.X.Scale, size.X.Offset, size.Y.Scale, size.Y.Offset),
            Position = dim2(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        objects["text"] = utility.new("TextLabel", {
            Parent = objects["Listbox"],
            FontFace = lib_font,
            TextColor3 = rgb(255, 255, 255),
            BorderColor3 = rgb(0, 0, 0),
            Text = data.name,
            Name = "text",
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = dim2(1, 0, 0, 15),
            BorderSizePixel = 0,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        utility.add_to_theme(objects["text"], {
            TextColor3 = "Text",
        })

        objects["UIStroke"] = utility.new("UIStroke", {
            Parent = objects["text"],
            Color = rgb(0, 0, 0),
            LineJoinMode = Enum.LineJoinMode.Miter
        })
        
        objects["RealBox"] = utility.new("ScrollingFrame", {
            Parent = objects["Listbox"],
            ScrollBarImageColor3 = library.theme.Accent,
            Active = true,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 1,
            Size = dim2(1, 0, 0, data.size),
            Name = "RealBox",
            Position = dim2(0, 0, 0, 18),
            BackgroundColor3 = library.theme.Element,
            BorderColor3 = rgb(0, 0, 0),
            BorderSizePixel = 0,
            CanvasSize = dim2(0, 0, 0, 0)
        })

        utility.add_to_theme(objects["RealBox"], {
            ScrollBarImageColor3 = "Accent",
            BackgroundColor3 = "Element"
        })
        
        objects["UIStroke2"] = utility.new("UIStroke", {
            Parent = objects["RealBox"],
            Color = library.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

        utility.add_to_theme(objects["UIStroke2"], {Color = "Border"});
        
        objects["UIListLayout"] = utility.new("UIListLayout", {
            Parent = objects["RealBox"],
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        if data.fade then
            objects["Fade"] = utility.new("Frame", {
                Parent = objects["Listbox"],
                AnchorPoint = vec2(0, 1),
                Name = "Fade",
                Position = dim2(0, 0, 1, 0),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, 0, 0, 35),
                BorderSizePixel = 0,
                BackgroundColor3 = library.theme.Inline
            })

            utility.add_to_theme(objects["Fade"], {
                BackgroundColor3 = "Inline";
            })
            
            objects["gradient"] = utility.new("UIGradient", {
                Parent = objects["Fade"],
                Rotation = -90,
                Transparency = numseq{numkey(0, 0), numkey(1, 1)},
                Name = "gradient"
            })
        end;

        function listbox:set(option)
            if not data.multi then
                if listbox.options[option] then
                    local option_objects = listbox.options[option];
                    option_objects.is_selected = true;

                    if library.tweening then
                        utility.tween(option_objects.text, {TextColor3 = library.theme.Accent});
                    else
                        option_objects.text.TextColor3 = library.theme.Accent;
                    end;

                    utility.change_object_theme(option_objects.text, {TextColor3 = "Accent"});

                    for index, value in listbox.options do
                        if value ~= option_objects then
                            value.is_selected = false;

                            if library.tweening then
                                utility.tween(value.text, {TextColor3 = library.theme.Text});
                            else
                                value.text.TextColor3 = library.theme.Text;
                            end;

                            utility.change_object_theme(value.text, {TextColor3 = "Text"});
                        end;
                    end;
                end;
            else
                for _, opt_name in option do
                    local table_index = listbox.options[opt_name];

                    if table_index then
                        table_index.is_selected = true;
                        if library.tweening then
                            utility.tween(table_index.text, {TextColor3 = library.theme.Accent});
                        else
                            table_index.text.TextColor3 = library.theme.Accent;
                        end;
                        utility.change_object_theme(table_index.text, {TextColor3 = "Accent"});
                    end;
                end;
            end;

            if data.callback then
                data.callback(listbox.value);
            end;
        end;

        function listbox:add_option(option)
            local sub_objects = {};
            sub_objects["option"] = utility.new("TextButton", {
                Parent = objects["RealBox"],
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                TextColor3 = rgb(0, 0, 0),
                BorderColor3 = rgb(0, 0, 0),
                Text = "",
                BackgroundTransparency = 1,
                Name = option,
                Size = dim2(1, 0, 0, 17),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundColor3 = rgb(255, 255, 255)
            })
            
            sub_objects["value"] = utility.new("TextLabel", {
                Parent = sub_objects["option"],
                FontFace = lib_font,
                TextColor3 = library.theme.Text,
                BorderColor3 = rgb(0, 0, 0),
                Text = option,
                Name = "value",
                Size = dim2(1, 0, 1, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = dim2(0, 4, 0, -1),
                BorderSizePixel = 0,
                TextSize = library.font_size,
                BackgroundColor3 = rgb(255, 255, 255)
            })

            utility.add_to_theme(sub_objects["value"], {TextColor3 = "Text"});
            
            sub_objects["UIStroke"] = utility.new("UIStroke", {
                Parent = sub_objects["value"],
                Color = rgb(0, 0, 0),
                LineJoinMode = Enum.LineJoinMode.Miter
            })

            local new_option = {
                name = option;
                object = sub_objects["option"];
                text = sub_objects["value"];
                is_selected = false;
            };

            function new_option:set(status)
                new_option.is_selected = status;

                if not data.multi then -- this is so ugly sry
                    if status then
                        listbox.value = new_option;

                        if library.tweening then
                            utility.tween(new_option.text, {TextColor3 = library.theme.Accent});
                        else
                            new_option.text.TextColor3 = library.theme.Accent;
                        end;

                        utility.change_object_theme(new_option.text, {TextColor3 = "Accent"});

                        for index, value in listbox.options do
                            if value ~= new_option then
                                value.is_selected = false;

                                if library.tweening then
                                    utility.tween(value.text, {TextColor3 = library.theme.Text});
                                else
                                    value.text.TextColor3 = library.theme.Text;
                                end;
                                
                                utility.change_object_theme(value.text, {TextColor3 = "Text"});
                            end;
                        end;
                    else
                        listbox.value = nil;

                        if library.tweening then
                            utility.tween(new_option.text, {TextColor3 = library.theme.Text});
                        else
                            new_option.text.TextColor3 = library.theme.Text;
                        end;

                        utility.change_object_theme(new_option.text, {TextColor3 = "Text"});
                    end;

                else
                    local index = table.find(listbox.value, new_option.name);

                    if index then
                        table.remove(listbox.value, index);
                        new_option.is_selected = false;
                    else
                        table.insert(listbox.value, new_option.name);
                        new_option.is_selected = true;
                    end;

                    if library.tweening then
                        utility.tween(new_option.text, {TextColor3 = index and library.theme.Text or library.theme.Accent});
                    else
                        new_option.text.TextColor3 = index and library.theme.Text or library.theme.Accent;
                    end;

                    utility.change_object_theme(new_option.text, {TextColor3 = index and "Text" or "Accent"});
                end;

                if data.callback then
                    data.callback(listbox.value);
                end;
            end;

            utility.connect(new_option.object.MouseButton1Down, function()
                new_option:set(not new_option.is_selected);
            end, new_option.name .. "clickEvent");

            self.options[new_option.name] = new_option
        end;

        for _, option in data.options do
            listbox:add_option(option);
        end;

        if data.default then
            listbox:set(data.default);
        end;

        library.flags[data.flag] = listbox;
        return listbox, objects;
    end;

    function utility.new_colorpicker(parent, size, position, data, no_text) -- beware of spaghetti code
        local objects = {};
        local colorpicker = {
            open = false,
            value = nil;
            current_tab = nil;
            current_animation = nil;
            transparency = 0;
            current_animation_intensity = nil;
            current_animation_time = nil;
            rainbow_hue = nil;
        };
        local sliding_color, sliding_alpha, sliding_hue = false, false, false;
        local current_color, hue, saturation, value, alpha;

        objects["colorpicker"] = utility.new("Frame", {
            Parent = parent,
            BackgroundTransparency = 1,
            Name = "colorpicker",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(size.X.Scale, size.X.Offset, size.Y.Scale, size.Y.Offset),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255),
            Position = dim2(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset);
        })
        
        objects["button_outline"] = utility.new("TextButton", {
            Parent = objects["colorpicker"],
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = rgb(0, 0, 0),
            BorderColor3 = rgb(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            AnchorPoint = vec2(1, 0),
            Name = "button_outline",
            Position = dim2(1, 0, 0, 0),
            Size = dim2(0, 19, 0, 11),
            BorderSizePixel = 0,
            TextSize = 14,
            BackgroundColor3 = rgb(53, 60, 108)
        })
        
        objects["inline"] = utility.new("Frame", {
            Parent = objects["button_outline"],
            Name = "inline",
            Position = dim2(0, 2, 0, 2),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -4, 1, -4),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(53, 60, 108)
        })
        
        objects["UIStroke"] = utility.new("UIStroke", {
            Parent = objects["inline"],
            Color = library.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        utility.add_to_theme(objects["UIStroke"], {Color = "Border"})
        objects["UIStroke2"] = utility.new("UIStroke", {
            Parent = objects["button_outline"],
            Color = library.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        utility.add_to_theme(objects["UIStroke2"], {Color = "Border"})

        objects["text"] = utility.new("TextLabel", {
            Parent = objects["colorpicker"],
            FontFace = lib_font,
            TextColor3 = library.theme.Text,
            BorderColor3 = rgb(0, 0, 0),
            Text = data.name,
            Name = "text",
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextSize = 12,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        if no_text then
            objects["text"]:Destroy();
            objects["text"] = nil;
        end

        if not no_text then
            utility.add_to_theme(objects["text"], {TextColor3 = "Text"})

            objects["UIStroke3"] = utility.new("UIStroke", {
                Parent = objects["text"],
                Color = rgb(0, 0, 0),
                LineJoinMode = Enum.LineJoinMode.Miter
            });
        end;
        
        objects["Window"] = utility.new("Frame", {
            Parent = objects["colorpicker"],
            Visible = false,
            Name = "Window",
            Position = dim2(0, 0, 0, 17),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 230, 0, 197),
            BorderSizePixel = 0,
            BackgroundColor3 = library.theme.Main
        })
        utility.add_to_theme(objects["Window"], {BackgroundColor3 = "Main"});
        objects["Holder"] = utility.new("Frame", {
            Parent = objects["Window"],
            Name = "Holder",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = library.theme.Inline
        })
        utility.add_to_theme(objects["Holder"], {BackgroundColor3 = "Inline"});
        objects["UIStroke4"] = utility.new("UIStroke", {
            Parent = objects["Window"],
            Color = library.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        utility.add_to_theme(objects["UIStroke4"], {Color = "Border"})
        objects["accent_line"] = utility.new("Frame", {
            Parent = objects["Holder"],
            Name = "accent_line",
            Interactable = false,
            BorderColor3 = rgb(3, 3, 3),
            Size = dim2(1, 0, 0, 2),
            BorderSizePixel = 0;
            BackgroundColor3 = library.theme.Accent
        })
        utility.add_to_theme(objects["accent_line"], {BackgroundColor3 = "Accent"});
        objects["misc_line"] = utility.new("Frame", {
            Parent = objects["accent_line"],
            Name = "misc_line",
            Position = dim2(0, 0, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 0, 1),
            BorderSizePixel = 0,
            BackgroundColor3 = library.theme.Main
        })
        utility.add_to_theme(objects["misc_line"], {BackgroundColor3 = "Main"});
        objects["Outline"] = utility.new("Frame", {
            Parent = objects["Holder"],
            Name = "Outline",
            Position = dim2(0, 6, 0, 18),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -12, 1, -24),
            BorderSizePixel = 0,
            BackgroundColor3 = library.theme.Main
        })
        
        utility.add_to_theme(objects["Outline"], {BackgroundColor3 = "Main"});

        objects["UIStroke5"] = utility.new("UIStroke", {
            Parent = objects["Outline"],
            Color = library.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

        utility.add_to_theme(objects["UIStroke5"], {Color = "Border"})
        
        objects["accent_line2"] = utility.new("Frame", {
            Parent = objects["Outline"],
            Name = "accent_line",
            Interactable = false,
            BorderColor3 = rgb(3, 3, 3),
            Size = dim2(1, 0, 0, 2),
            BackgroundColor3 = library.theme.Accent
        })

        utility.add_to_theme(objects["accent_line2"], {BackgroundColor3 = "Accent"});
        
        objects["misc_line2"] = utility.new("Frame", {
            Parent = objects["accent_line2"],
            Name = "misc_line",
            Position = dim2(0, 0, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 0, 1),
            BorderSizePixel = 0,
            BackgroundColor3 = library.theme.Main
        })

        utility.add_to_theme(objects["misc_line2"], {BackgroundColor3 = "Main"});

        objects["windowtitle"] = utility.new("TextLabel", {
            Parent = objects["Window"],
            FontFace = lib_font,
            TextColor3 = library.theme.Text,
            BorderColor3 = rgb(0, 0, 0),
            Text = data.name,
            Name = "title",
            Size = dim2(1, -18, 0, 18),
            Position = dim2(0, 6, 0, 1),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
            RichText = true,
            TextSize = library.font_size,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        utility.add_to_theme(objects["windowtitle"], {TextColor3 = "Text"});
        
        objects["UIStroke6"] = utility.new("UIStroke", {
            Parent = objects["windowtitle"],
            LineJoinMode = Enum.LineJoinMode.Miter
        })
        
        objects["closebutton"] = utility.new("TextButton", {
            Parent = objects["Window"],
            FontFace = lib_font,
            TextColor3 = library.theme.Text,
            BorderColor3 = rgb(0, 0, 0),
            Text = "x",
            AnchorPoint = vec2(1, 0),
            Name = "closebutton",
            BackgroundTransparency = 1,
            Position = dim2(1, 0, 0, 0),
            Size = dim2(0, 20, 0, 17),
            BorderSizePixel = 0,
            TextSize = library.font_size,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        utility.add_to_theme(objects["closebutton"], {TextColor3 = "Text"});
        
        objects["UIStroke7"] = utility.new("UIStroke", {
            Parent = objects["closebutton"],
            LineJoinMode = Enum.LineJoinMode.Miter
        })

        objects["tabsHolder"] = utility.new("Frame", {
            Parent = objects["Outline"],
            Name = "tabs",
            BackgroundTransparency = 1,
            Position = dim2(0, 0, 0, 3),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 0, 18),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        objects["UIListLayout"] = utility.new("UIListLayout", {
            Parent = objects["tabsHolder"],
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = dim(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        objects["PickerTab"] = utility.new("Frame", {
            Parent = objects["tabsHolder"],
            Name = "PickerTab",
            BorderColor3 = rgb(3, 3, 3),
            Size = dim2(1, 0, 1, 0),
            BackgroundColor3 = library.theme.Inline
        })

        utility.add_to_theme(objects["PickerTab"], {BackgroundColor3 = "Inline", BorderColor3 = "Border"});
        
        objects["PickerTabButton"] = utility.new("TextButton", {
            Parent = objects["PickerTab"],
            FontFace = lib_font,
            TextColor3 = library.theme["Text Inactive"],
            BorderColor3 = rgb(3, 4, 4),
            Text = "Picker",
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 1, 0),
            TextSize = library.font_size,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        utility.add_to_theme(objects["PickerTabButton"], {TextColor3 = "Text Inactive"})
        
        objects["UIStroke8"] = utility.new("UIStroke", {
            Parent = objects["PickerTabButton"],
            Color = rgb(0, 0, 0),
            LineJoinMode = Enum.LineJoinMode.Miter
        })
        
        objects["AnimationsTab"] = utility.new("Frame", {
            Parent = objects["tabsHolder"],
            Name = "AnimationsTab",
            BorderColor3 = rgb(3, 4, 4),
            Size = dim2(1, 0, 1, 0),
            BackgroundColor3 = library.theme.Inline
        })

        utility.add_to_theme(objects["AnimationsTab"], {BackgroundColor3 = "Inline", BorderColor3 = "Border"});
        
        objects["AnimationsTabButton"] = utility.new("TextButton", {
            Parent = objects["AnimationsTab"],
            FontFace = lib_font,
            TextColor3 = library.theme["Text Inactive"],
            BorderColor3 = rgb(0, 0, 0),
            Text = "Animations",
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextSize = library.font_size,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        utility.add_to_theme(objects["AnimationsTabButton"], {TextColor3 = "Text Inactive"});
        
        objects["UIStroke9"] = utility.new("UIStroke", {
            Parent = objects["AnimationsTabButton"],
            LineJoinMode = Enum.LineJoinMode.Miter
        })
        
        objects["ColorTab"] = utility.new("Frame", {
            Parent = objects["tabsHolder"],
            Name = "ColorTab",
            BorderColor3 = library.theme.Border,
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 1,
            BackgroundColor3 = library.theme.Inline
        })

        utility.add_to_theme(objects["ColorTab"], {BackgroundColor3 = "Inline", BorderColor3 = "Border"});
        
        objects["ColorTabButton"] = utility.new("TextButton", {
            Parent = objects["ColorTab"],
            FontFace = lib_font,
            TextColor3 = library.theme["Text Inactive"],
            BorderColor3 = rgb(0, 0, 0),
            Text = "Color",
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextSize = library.font_size,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        utility.add_to_theme(objects["ColorTabButton"], {TextColor3 = "Text Inactive"});

        objects["UIStroke10"] = utility.new("UIStroke", {
            Parent = objects["ColorTabButton"],
            LineJoinMode = Enum.LineJoinMode.Miter
        })

        objects["contentCotainer"] = utility.new("Frame", {
            Parent = objects["Outline"],
            Name = "content",
            BackgroundTransparency = 1,
            Position = dim2(0, 0, 0, 25),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, -30),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        objects["PickerTabContent"] = utility.new("Frame", {
            Parent = objects["contentCotainer"],
            Visible = false,
            BackgroundTransparency = 1,
            Name = "PickerTab",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        objects["AnimationsTabContent"] = utility.new("Frame", {
            Parent = objects["contentCotainer"],
            Visible = false,
            BackgroundTransparency = 1,
            Name = "AnimationsTab",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        objects["ColorTabContent"] = utility.new("Frame", {
            Parent = objects["contentCotainer"],
            Visible = false,
            BackgroundTransparency = 1,
            Name = "ColorTab",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        objects["PickerColor"] = utility.new("TextButton", {
            Parent = objects["PickerTabContent"],
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = rgb(0, 0, 0),
            BorderColor3 = rgb(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            Name = "Color",
            Position = dim2(0, 7, 0, 5),
            Size = dim2(0, 180, 0, 110),
            BorderSizePixel = 0,
            TextSize = 14,
            BackgroundColor3 = rgb(53, 60, 108)
        })
        
        objects["SaturationIMG"] = utility.new("ImageLabel", {
            Parent = objects["PickerColor"],
            Image = "rbxassetid://130624743341203",
            BackgroundTransparency = 1,
            Name = "Saturation",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        objects["ValueIMG"] = utility.new("ImageLabel", {
            Parent = objects["PickerColor"],
            Image = "rbxassetid://96192970265863",
            BackgroundTransparency = 1,
            Name = "Value",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        objects["UIStroke11"] = utility.new("UIStroke", {
            Parent = objects["PickerColor"],
            Color = library.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

        utility.add_to_theme(objects["UIStroke11"], {Color = "Border"});
        
        objects["ColorDragger"] = utility.new("Frame", {
            Parent = objects["PickerColor"],
            Name = "Dragger",
            Position = dim2(0, 3, 0, 3),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 3, 0, 3),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        objects["UIStroke12"] = utility.new("UIStroke", {
            Parent = objects["ColorDragger"],
            Color = library.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

        utility.add_to_theme(objects["UIStroke12"], {Color = "Border"});
        
        objects["PickerHue"] = utility.new("ImageButton", {
            Parent = objects["PickerTabContent"],
            Image = "rbxassetid://133334110106525",
            Name = "Hue",
            Position = dim2(1, -20, 0, 5),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 13, 0, 110),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        objects["UIStroke13"] = utility.new("UIStroke", {
            Parent = objects["PickerHue"],
            Color = library.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

        utility.add_to_theme(objects["UIStroke13"], {Color = "Border"});
        
        objects["HueDragger"] = utility.new("Frame", {
            Parent = objects["PickerHue"],
            Name = "Dragger",
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 0, 2),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        objects["UIStroke14"] = utility.new("UIStroke", {
            Parent = objects["HueDragger"],
            Color = library.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

        utility.add_to_theme(objects["UIStroke14"], {Color = "Border"});
        
        objects["PickerAlpha"] = utility.new("TextButton", {
            Parent = objects["PickerTabContent"],
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = rgb(0, 0, 0),
            BorderColor3 = rgb(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            Name = "Alpha",
            Position = dim2(0, 7, 1, -17),
            Size = dim2(0, 180, 0, 13),
            BorderSizePixel = 0,
            TextSize = 14,
            BackgroundColor3 = rgb(53, 60, 108)
        })
        
        objects["CheckersIMG"] = utility.new("ImageLabel", {
            Parent = objects["PickerAlpha"],
            ScaleType = Enum.ScaleType.Tile,
            BorderColor3 = rgb(0, 0, 0),
            Image = "http://www.roblox.com/asset/?id=18274452449",
            BackgroundTransparency = 1,
            Name = "Checkers",
            Size = dim2(1, 0, 1, 0),
            TileSize = dim2(0, 6, 0, 6),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        objects["gradient5"] = utility.new("UIGradient", {
            Parent = objects["CheckersIMG"],
            Transparency = numseq{numkey(0, 1), numkey(1, 0)},
            Name = "gradient"
        })
        
        objects["UIStroke15"] = utility.new("UIStroke", {
            Parent = objects["PickerAlpha"],
            Color = library.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        
        utility.add_to_theme(objects["UIStroke15"], {Color = "Border"});

        objects["AlphaDragger"] = utility.new("Frame", {
            Parent = objects["PickerAlpha"],
            Name = "Dragger",
            Position = dim2(1, -74, 0, 0),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 2, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        objects["UIStroke16"] = utility.new("UIStroke", {
            Parent = objects["AlphaDragger"],
            Color = library.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

        utility.add_to_theme(objects["UIStroke16"], {Color = "Border"});
        
        objects["CurrentColorPickerTab"] = utility.new("Frame", {
            Parent = objects["PickerTabContent"],
            Name = "CurrentColor",
            Position = dim2(1, -20, 1, -17),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(0, 13, 0, 13),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(53, 60, 108)
        })
        
        objects["UIStroke17"] = utility.new("UIStroke", {
            Parent = objects["CurrentColorPickerTab"],
            Color = library.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

        utility.add_to_theme(objects["UIStroke17"], {Color = "Border"});
        
        objects["CheckersIMG2"] = utility.new("ImageLabel", {
            Parent = objects["CurrentColorPickerTab"],
            ScaleType = Enum.ScaleType.Tile,
            ImageTransparency = 0.5,
            BorderColor3 = rgb(0, 0, 0),
            Image = "http://www.roblox.com/asset/?id=18274452449",
            BackgroundTransparency = 1,
            Name = "Checkers",
            Size = dim2(1, 0, 1, 0),
            TileSize = dim2(0, 6, 0, 6),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        function colorpicker:set_open(bool)
            colorpicker.open = bool;
            objects["Window"].Visible = bool;

            for i,v in objects["colorpicker"]:GetDescendants() do
                if not v.ClassName:find("UI") then
                    v.ZIndex = bool and 15 or 1;
                end;
            end;
        end;

        function colorpicker:switch_tab(tab) -- sorry
            colorpicker.current_tab = tab;
            objects["PickerTabContent"].Visible = tab == "picker" and true or false;
            objects["AnimationsTabContent"].Visible = tab == "animations" and true or false;
            objects["ColorTabContent"].Visible = tab == "color" and true or false;

            if library.tweening then
                utility.tween(objects["PickerTabButton"], {TextColor3 = tab == "picker" and library.theme["Text"] or library.theme["Text Inactive"]});
                utility.tween(objects["AnimationsTabButton"], {TextColor3 = tab == "animations" and library.theme["Text"] or library.theme["Text Inactive"]});
                utility.tween(objects["ColorTabButton"], {TextColor3 = tab == "color" and library.theme["Text"] or library.theme["Text Inactive"]});

                utility.tween(objects["PickerTab"], {BackgroundColor3 = tab == "picker" and library.theme.Main or library.theme.Inline});
                utility.tween(objects["AnimationsTab"], {BackgroundColor3 = tab == "animations" and library.theme.Main or library.theme.Inline});
                utility.tween(objects["ColorTab"], {BackgroundColor3 = tab == "color" and library.theme.Main or library.theme.Inline});
            else
                objects["PickerTabButton"].TextColor3 = tab == "picker" and library.theme["Text"] or library.theme["Text Inactive"];
                objects["AnimationsTabButton"].TextColor3 = tab == "animations" and library.theme["Text"] or library.theme["Text Inactive"];
                objects["ColorTabButton"].TextColor3 = tab == "color" and library.theme["Text"] or library.theme["Text Inactive"];

                objects["PickerTab"].BackgroundColor3 = tab == "picker" and library.theme.Main or library.theme.Inline;
                objects["AnimationsTab"].BackgroundColor3 = tab == "animations" and library.theme.Main or library.theme.Inline;
                objects["ColorTab"].BackgroundColor3 = tab == "color" and library.theme.Main or library.theme.Inline;
            end;

            objects["PickerTab"].BorderSizePixel = tab == "picker" and 0 or 1;
            objects["AnimationsTab"].BorderSizePixel = tab == "animations" and 0 or 1;
            objects["ColorTab"].BorderSizePixel = tab == "color" and 0 or 1;
        end;

        utility.connect(objects["PickerTabButton"].MouseButton1Down, function()
            colorpicker:switch_tab("picker");
        end, data.name .. "_PickerTabButton");

        utility.connect(objects["AnimationsTabButton"].MouseButton1Down, function()
            colorpicker:switch_tab("animations");
        end, data.name .. "_AnimationsTabButton");

        utility.connect(objects["ColorTabButton"].MouseButton1Down, function()
            colorpicker:switch_tab("color");
        end, data.name .. "_ColorTabButton");

        utility.connect(objects["button_outline"].MouseButton1Down, function()
            colorpicker:set_open(not colorpicker.open);
        end, data.name .. "_openEvent");

        function colorpicker:update()
            objects["button_outline"].BackgroundColor3 = Color3.fromHSV(hue, saturation, value);
            objects["inline"].BackgroundColor3 = Color3.fromHSV(hue, saturation, value);
            objects["PickerAlpha"].BackgroundColor3 = Color3.fromHSV(hue, saturation, value);

            objects["PickerColor"].BackgroundColor3 = Color3.fromHSV(hue, 1, 1);
            objects["CurrentColorPickerTab"].BackgroundColor3 = Color3.fromHSV(hue, saturation, value);

            objects["CheckersIMG2"].ImageTransparency = alpha;

            current_color = Color3.fromHSV(hue, saturation, value);
            colorpicker.value = current_color;

            if data.callback then
                data.callback(colorpicker.value);
            end;
        end;

        function colorpicker:set(color, alpha_value)
            if (type(color) == "table") then
                alpha = color[4];
                color = Color3.fromRGB(color[1], color[2], color[3]);
            end;

            if (type(color) == "string") then
                color = Color3.fromHex(color);
            end;

            hue, saturation, value = color:ToHSV();
            alpha = alpha_value or 0;

            colorpicker:update();

            local color_position_x, color_position_y = math.clamp(1 - saturation, 0.000, 0.985), math.clamp(1 - value, 0.000, 1 - 0.98);
            objects["ColorDragger"].Position = dim2(color_position_x, 0, color_position_y, 0);
            local hue_position_y = math.clamp(hue, 0.005, 0.985);
            objects["HueDragger"].Position = dim2(0, 0, hue_position_y, 0);
            local alpha_position = math.clamp(1 - alpha, 0.000, 1);
            objects["AlphaDragger"].Position = dim2(alpha_position, 0, 0, 0);

            current_color = Color3.fromHSV(hue, saturation, value);
            colorpicker.value = current_color;
            colorpicker.transparency = alpha;
        end;
        
        function colorpicker:slide_hue(input)
            local hue_value = math.clamp(((input.Position.Y - 56) - objects["PickerHue"].AbsolutePosition.Y) / objects["PickerHue"].AbsoluteSize.Y, 0, 1);
            local position_x = math.clamp(((input.Position.Y - 56) - objects["PickerHue"].AbsolutePosition.Y) / objects["PickerHue"].AbsoluteSize.Y, 0, 0.985);

            hue = hue_value;
            objects["HueDragger"].Position = dim2(0, 0, position_x, 0);
            colorpicker:update();
        end;

        function colorpicker:slide_alpha(input)
            local alpha_value = math.clamp(1 - (input.Position.X - objects["PickerAlpha"].AbsolutePosition.X) / objects["PickerAlpha"].AbsoluteSize.X, 0, 1);
            local alpha_position = math.clamp((input.Position.X - objects["PickerAlpha"].AbsolutePosition.X) / objects["PickerAlpha"].AbsoluteSize.X, 0, 1);

            alpha = alpha_value;
            colorpicker.transparency = alpha;
            objects["AlphaDragger"].Position = dim2(alpha_position, 0, 0, 0);
            colorpicker:update();
        end;

        function colorpicker:slide_color(input)
            local value_x = math.clamp(1 - (input.Position.X - objects["PickerColor"].AbsolutePosition.X) / objects["PickerColor"].AbsoluteSize.X, 0, 0.985);
            local value_y = math.clamp(1 - (input.Position.Y - objects["PickerColor"].AbsolutePosition.Y) / objects["PickerColor"].AbsoluteSize.Y, 0, 0.98);

            local position_x = math.clamp((input.Position.X - objects["PickerColor"].AbsolutePosition.X) / objects["PickerColor"].AbsoluteSize.X, 0, 0.985);
            local position_y = math.clamp(((input.Position.Y - 56) - objects["PickerColor"].AbsolutePosition.Y) / objects["PickerColor"].AbsoluteSize.Y, 0, 0.98);
        
            saturation = value_x;
            value = value_y;

            objects["ColorDragger"].Position = dim2(position_x, 0, position_y, 0);
            colorpicker:update();
        end;

        utility.connect(objects["PickerHue"].InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding_hue = true;
                colorpicker:slide_hue({Position = user_input_service:GetMouseLocation()});
            end;
        end, data.name .. "_PickerHue");

        utility.connect(objects["PickerHue"].InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding_hue = false;
            end;
        end, data.name .. "_PickerHue2");

        utility.connect(objects["PickerColor"].InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding_color = true;
                colorpicker:slide_color({Position = user_input_service:GetMouseLocation()});
            end;
        end, data.name .. "_PickerColor");

        utility.connect(objects["PickerColor"].InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding_color = false;
            end;
        end, data.name .. "_PickerColor2");

        utility.connect(objects["PickerAlpha"].InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding_alpha = true;
                colorpicker:slide_alpha({Position = user_input_service:GetMouseLocation()});
            end;
        end, data.name .. "_PickerAlpha");

        utility.connect(objects["PickerAlpha"].InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding_alpha = false;
            end;
        end, data.name .. "_PickerAlpha2");

        utility.connect(user_input_service.InputChanged, function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                if sliding_hue then
                    colorpicker:slide_hue({Position = user_input_service:GetMouseLocation()});
                elseif sliding_color then
                    colorpicker:slide_color({Position = user_input_service:GetMouseLocation()});
                elseif sliding_alpha then
                    colorpicker:slide_alpha({Position = user_input_service:GetMouseLocation()});
                end;
            end;
        end, data.name .. "_InputChanged");

        objects["animations_listbox"] = utility.new_listbox(
            objects["AnimationsTabContent"],
            dim2(0, 85, 0, 78),
            dim2(0, 7, 0, 85),
            {
                name = "Animations",
                flag = data.name .. "_AnimationSelected",
                options = {"Rainbow","Fade","Fade Alpha", "Random"};
                size = 65,
                multi = false,
                fade = false;
                callback = function(v)
                    colorpicker.current_animation = v;
                end;
            }
        );

        objects["animations_intensity_slider"] = utility.new_slider(
            objects["AnimationsTabContent"],
            dim2(0, 110, 0, 29),
            dim2(0, 100, 0, 5),
            {
                name = "Intensity",
                flag = data.name .. "_AnimationIntensity",
                default = 25,
                min = 0,
                max = 100,
                suffix = "%",
                callback = function(v)
                    colorpicker.current_animation_intensity = v;
                end;
            }
        )

        objects["animations_time_slider"] = utility.new_slider(
            objects["AnimationsTabContent"],
            dim2(0, 110, 0, 29),
            dim2(0, 100, 0, 54),
            {
                name = "Time",
                flag = data.name .. "_AnimationTime",
                default = 2.5,
                min = 0,
                max = 5,
                decimals = 0.1;
                suffix = "%",
                callback = function(v)
                    colorpicker.current_animation_time = v;
                end;
            }
        )

        utility.connect(objects["closebutton"].MouseButton1Down, function()
            objects["Window"].Visible = false;
            colorpicker.open = false;
        end, data.name .. "_closebutton");

        if data.default then
            colorpicker:set(data.default, data.alpha)
        end;

        return colorpicker, objects;
    end;

    function library:Window(Data)
        local window = {
            name = Data.Name or Data.name or 'Window',
            objects = {};
        };

        local objects = {};

        objects["Main_Frame"] = utility.new("Frame", {
            Parent = self.holder,
            AnchorPoint = vec2(0.5, 0.5),
            Name = "Main_Frame",
            Position = dim2(0.5, 0, 0.5, 0),
            Size = dim2(0, 450, 0, 600),
            BorderColor3 = rgb(0, 0, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = library.theme.Main;
        })

        utility.add_to_theme(objects["Main_Frame"], {
            BackgroundColor3 = "Main";
        })
        
        objects["holder"] = utility.new("Frame", {
            Parent = objects["Main_Frame"],
            Name = "holder",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = library.theme.Main
        })

        objects["contarst"] = utility.new("UIGradient", {
            Parent = objects["holder"],
            Rotation = 90,
            Name = "contarst",
            Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(116, 116, 116))}
        })        

        utility.add_to_theme(objects["holder"], {
            BackgroundColor3 = "Main";
        })
        
        objects["title"] = utility.new("TextLabel", {
            Parent = objects["holder"],
            FontFace = lib_font,
            TextColor3 = self.theme.Text,
            BorderColor3 = rgb(0, 0, 0),
            Text = window.name,
            Name = "title",
            Size = dim2(0, 200, 0, 18),
            Position = dim2(0, 3, 0, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
            RichText = true,
            TextSize = self.font_size,
            BackgroundColor3 = rgb(255, 255, 255)
        })

        utility.add_to_theme(objects["title"], {
            TextColor3 = "Text";
        })
        
        objects["UIStroke9"] = utility.new("UIStroke", {
            Parent = objects["title"],
            LineJoinMode = Enum.LineJoinMode.Miter
        })
        
        objects["outline"] = utility.new("Frame", {
            Parent = objects["holder"],
            Name = "outline",
            Position = dim2(0, 6, 0, 18),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -12, 1, -24),
            BorderSizePixel = 0,
            BackgroundColor3 = self.theme.Main
        })

        objects["UIStroke1"] = utility.new("UIStroke", {
            Parent = objects["outline"],
            Color = self.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })        

        utility.add_to_theme(objects["UIStroke1"], {
            Color = "Border";
        })

        utility.add_to_theme(objects["outline"], {
            BackgroundColor3 = "Main";
        })
        
        objects["inline"] = utility.new("Frame", {
            Parent = objects["outline"],
            Name = "inline",
            Position = dim2(0, 1, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = self.theme.Inline
        })

        utility.add_to_theme(objects["inline"], {
            BackgroundColor3 = "Inline";
        })
        
        objects["inner_line"] = utility.new("Frame", {
            Parent = objects["inline"],
            Name = "inner_line",
            Position = dim2(0, 2, 0, 2),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -4, 1, -4),
            BorderSizePixel = 0,
            BackgroundColor3 = self.theme.Main
        })

        utility.add_to_theme(objects["inner_line"], {
            BackgroundColor3 = "Main";
        })
        
        objects["UIGradient"] = utility.new("UIGradient", {
            Parent = objects["inner_line"],
            Rotation = 90,
            Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(156, 156, 156))}
        })

        objects["UIStroke2"] = utility.new("UIStroke", {
            Parent = objects["inner_line"],
            Color = self.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })        

        utility.add_to_theme(objects["UIStroke2"], {
            Color = "Border";
        })
        
        objects["container"] = utility.new("Frame", {
            Parent = objects["inner_line"],
            Name = "container",
            Position = dim2(0, 3, 0, 3),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -6, 1, -6),
            BorderSizePixel = 0,
            BackgroundColor3 = self.theme.Main
        })

        objects["UIStroke3"] = utility.new("UIStroke", {
            Parent = objects["container"],
            Color = self.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })        

        utility.add_to_theme(objects["UIStroke3"], {
            Color = "Border";
        })
        
        utility.add_to_theme(objects["container"], {
            BackgroundColor3 = "Main";
        })

        objects["UIGradient3"] = utility.new("UIGradient", {
            Parent = objects["container"],
            Rotation = 90,
            Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(130, 130, 130))}
        })
        
        objects["accent_line"] = utility.new("Frame", {
            Parent = objects["container"],
            Name = "accent_line",
            BorderColor3 = rgb(3, 3, 3),
            Size = dim2(1, 0, 0, 2),
            BackgroundColor3 = self.theme.Accent
        })

        utility.add_to_theme(objects["accent_line"], {
            BackgroundColor3 = "Accent";
        })
        
        objects["misc_line"] = utility.new("Frame", {
            Parent = objects["accent_line"],
            Name = "misc_line",
            Position = dim2(0, 0, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 0, 1),
            BorderSizePixel = 0,
            BackgroundColor3 = self.theme.Main
        })

        utility.add_to_theme(objects["misc_line"], {
            BackgroundColor3 = "Accent";
        })
        
        objects["tabs"] = utility.new("Frame", {
            Parent = objects["container"],
            Name = "tabs",
            Position = dim2(0, 0, 0, 3),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 0, 18),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(16, 21, 29)
        })

        objects["content"] = utility.new("Frame", {
            Parent = objects["container"],
            Name = "content",
            BackgroundTransparency = 1,
            Position = dim2(0, 3, 0, 25),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -6, 1, -30),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        objects["UIGradient2"] = utility.new("UIGradient", {
            Parent = objects["tabs"],
            Rotation = 90,
            Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(127, 127, 127))}
        })
        
        objects["UIListLayout2"] = utility.new("UIListLayout", {
            Parent = objects["tabs"],
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = dim(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        objects["accent_line2"] = utility.new("Frame", {
            Parent = objects["Main_Frame"],
            Name = "accent_line",
            BorderColor3 = rgb(3, 3, 3),
            Size = dim2(1, 0, 0, 2),
            BackgroundColor3 = self.theme.Accent
        })
        
        objects["misc_line2"] = utility.new("Frame", {
            Parent = objects["accent_line2"],
            Name = "misc_line",
            Position = dim2(0, 0, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 0, 1),
            BorderSizePixel = 0,
            BackgroundColor3 = self.theme.Main
        })

        objects["UIStroke4"] = utility.new("UIStroke", {
            Parent = objects["Main_Frame"],
            Color = self.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })        

        utility.add_to_theme(objects["UIStroke4"], {
            Color = "Border";
        })

        utility.add_to_theme(objects["accent_line2"], {
            BackgroundColor3 = "Accent";
        })
    
        utility.add_to_theme(objects["misc_line2"], {
            BackgroundColor3 = "Accent";
        })

        window.objects = {
            tabs = objects["tabs"],
            content = objects["content"]
        };

        do -- dragging
            local gui = objects["Main_Frame"]
            local drag_input, drag_start, start_position
    
            local function update(input)
                local delta = input.Position - drag_start;
                gui.Position = UDim2.new(start_position.X.Scale, start_position.X.Offset + delta.X, start_position.Y.Scale, start_position.Y.Offset + delta.Y);
            end;

            utility.connect(gui.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    library.dragging = true;
                    drag_start = input.Position;
                    start_position = gui.Position;
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            library.dragging = false;
                        end;
                    end);
                end;
            end, "windowDragging")
    
            utility.connect(gui.InputChanged, function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    drag_input = input;
                end;
            end, "WindowInputChanged")

            utility.connect(user_input_service.InputChanged, function(input)
                if input == drag_input and library.dragging then
                    update(input);
                end;
            end, "userinputchangedwindowdragging")
        end;

        return setmetatable(window, self);
    end;

    function library:Tab(Data)
        local tab = {
            window = self,
            name = Data.Name or Data.name or 'Tab',
            objects = {};
        };

        local _, objects = utility.new_tab(true, tab.window.objects.tabs, tab.window.objects.content, 418, 532, 0, 0, self.real_tabs, self.tabs, tab.name);

        tab.objects = {
            main = objects["section_holders"];
            left = objects["left"];
            right = objects["right"];
        };

        return setmetatable(tab, self.tabs);
    end;

    function library.tabs:Section(Data)
        local section = {
            window = self.window,
            tab = self,
            name = Data.Name or Data.name or 'Section',
            side = Data.Side or Data.side or 'Left',
            is_scrollable = Data.Scrollable or Data.scrollable or false,
            automatic_size = Data.AutoSize or Data.autosize or true,
            size = Data.Size or Data.size or nil,
            objects = {};
            elements = {};
        };

        local objects = {};
        objects["section"] = nil;
        if (section.is_scrollable) then
            objects["section"] = utility.new("ScrollingFrame", {
                Parent = section.side:lower() == "left" and section.tab.objects.left or section.side:lower() == "right" and section.tab.objects.right,
                Name = section.name,
                Size = dim2(1, 0, 0,section.size or 31),
                BorderColor3 = rgb(0, 0, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = library.theme.Main,
                CanvasSize = dim2(0, 0, 0, 0),
                ScrollBarThickness = 1,
                ScrollBarImageColor3 = library.theme.Accent,
                AutomaticCanvasSize = section.automatic_size and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
            })

            utility.add_to_theme(objects["section"], {
                BackgroundColor3 = "Main",
                ScrollBarImageColor3 = "Accent"
            })
        else
            objects["section"] = utility.new("Frame", {
                Parent = section.side:lower() == "left" and section.tab.objects.left or section.side:lower() == "right" and section.tab.objects.right,
                Name = section.name,
                Size = dim2(1, 0, 0, section.size or 31),
                BorderColor3 = rgb(0, 0, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = library.theme.Main,
                AutomaticSize = section.automatic_size and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
            })

            utility.add_to_theme(objects["section"], {
                BackgroundColor3 = "Main"
            })
        end;
        
        objects["brightness"] = utility.new("UIGradient", {
            Parent = objects["section"],
            Rotation = -90,
            Name = "brightness",
            Color = rgbseq{rgbkey(0, rgb(69, 86, 124)), rgbkey(0.404, rgb(62, 78, 113)), rgbkey(1, rgb(255, 255, 255))}
        })        
        
        objects["UIStroke"] = utility.new("UIStroke", {
            Parent = objects["section"],
            Color = library.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

        utility.add_to_theme(objects["UIStroke"], {
            Color = "Border"
        })
        
        objects["accent_line"] = utility.new("Frame", {
            Parent = objects["section"],
            Name = "accent_line",
            Interactable = false,
            BorderColor3 = rgb(3, 3, 3),
            Size = dim2(1, 0, 0, 2),
            BackgroundColor3 = library.theme.Accent
        })

        utility.add_to_theme(objects["accent_line"], {
            BackgroundColor3 = "Accent"
        })
        
        objects["misc_line"] = utility.new("Frame", {
            Parent = objects["accent_line"],
            Name = "misc_line",
            Position = dim2(0, 0, 0, 1),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, 0, 0, 1),
            BorderSizePixel = 0,
            BackgroundColor3 = library.theme.Main
        })

        utility.add_to_theme(objects["misc_line"], {
            BackgroundColor3 = "Main"
        })
        
        objects["text"] = utility.new("TextLabel", {
            Parent = objects["section"],
            FontFace = lib_font,
            TextColor3 = library.theme.Text,
            BorderColor3 = rgb(0, 0, 0),
            Text = section.name,
            Name = "text",
            Size = dim2(1, 0, 0, 15),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = dim2(0, 5, 0, 3),
            BorderSizePixel = 0,
            TextSize = library.font_size,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        objects["UIStroke2"] = utility.new("UIStroke", {
            Parent = objects["text"],
            Color = library.theme.Border,
            LineJoinMode = Enum.LineJoinMode.Miter
        })

        utility.add_to_theme(objects["UIStroke2"], {
            Color = "Border"
        })
        
        objects["content"] = utility.new("Frame", {
            Parent = objects["section"],
            Name = "content",
            BackgroundTransparency = 1,
            Position = dim2(0, 5, 0, 21),
            BorderColor3 = rgb(0, 0, 0),
            Size = dim2(1, -10, 1, -15),
            BorderSizePixel = 0,
            BackgroundColor3 = rgb(255, 255, 255)
        })
        
        objects["UIListLayout"] = utility.new("UIListLayout", {
            Parent = objects["content"],
            Padding = dim(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        section.objects = {
            main = objects["section"],
            content = objects["content"],
        };

        return setmetatable(section, library.sections);
    end;

    function library.sections:Toggle(Data)
        local toggle = {
            window = self.window,
            tab = self.tab,
            section = self,
            name = Data.Name or Data.name or 'Toggle',
            flag = Data.Flag or Data.flag or utility.next_flag();
            default = Data.Default or Data.default or false,
            callback = Data.Callback or Data.callback or function() end;
            sub_elements = Data.SubElements or Data.subelements or false;
        };

        local new_toggle, objects = utility.new_toggle(
            toggle.section.objects.content,
            dim2(1,0,0,13),
            dim2(0,0,0,0),
            toggle
        );

        toggle.section.elements[#toggle.section.elements + 1] = new_toggle;

        function toggle:Colorpicker(data)
            local colorpicker = {
                name = Data.Name or data.name or 'Colorpicker';
                flag = Data.Flag or data.flag or utility.next_flag();
                default = Data.Default or data.default or rgb(255, 255, 255);
                callback = Data.Callback or data.callback or function() end;
                alpha = Data.Alpha or data.alpha or 0;
            };

            local new_colorpicker, colorpikcer_objects = utility.new_colorpicker(
                objects["toggle"],
                dim2(1, 0, 0, 11),
                dim2(0, 0, 0, 0),
                colorpicker,
                true
            );

            return colorpicker, new_colorpicker, colorpikcer_objects;
        end;

        return toggle, new_toggle, objects;
    end;

    function library.sections:Button(Data)
        local button = {
            window = self.window,
            tab = self.tab,
            section = self,
            name = Data.Name or Data.name or 'Button',
            callback = Data.Callback or Data.callback or function() end;
        };

        local new_button, objects = utility.new_button(
            button.section.objects.content,
            dim2(1,0,0,15),
            dim2(0,0,0,0),
            button
        );

        button.section.elements[#button.section.elements+1] = new_button

        return button, new_button, objects;
    end;

    function library.sections:Slider(Data)
        local slider = {
            window = self.window,
            tab = self.tab,
            section = self,
            name = Data.Name or Data.name or 'Slider',
            flag = Data.Flag or Data.flag or utility.next_flag();
            default = Data.Default or Data.default or 0,
            min = Data.Min or Data.min or 0,
            max = Data.Max or Data.max or 100,
            callback = Data.Callback or Data.callback or function() end;
            suffix = Data.Sub or Data.sub or Data.suffix or Data.Suffix or "";
            decimals = Data.Decimals or Data.decimals or 1;
            infinite = Data.Infinite or Data.infinite or false;
        };

        local new_slider, objects = utility.new_slider(
            slider.section.objects.content,
            dim2(1, 0, 0, 29),
            dim2(0, 0, 0, 0),
            slider
        );

        return slider, new_slider, objects;
    end;

    function library.sections:Dropdown(Data)
        local dropdown = {
            window = self.window,
            tab = self.tab,
            section = self,
            name = Data.Name or Data.name or 'Dropdown',
            flag = Data.Flag or Data.flag or utility.next_flag();
            default = Data.Default or Data.default or "--",
            callback = Data.Callback or Data.callback or function() end;
            options = Data.Options or Data.options or {};
            multi = Data.Multi or Data.multi or false;
        };

        local new_dropdown, objects = utility.new_dropdown(
            dropdown.section.objects.content,
            dim2(1, 0, 0, 32),
            dim2(0, 0, 0, 0),
            dropdown
        )

        return dropdown, new_dropdown, objects;
    end;
end;

local window = library:Window({Name = "bitchbot menu"})

local combat_tab = window:Tab({Name = "combat"});
local misc_tab = window:Tab({Name = "misc"});
local visuals_tab = window:Tab({Name = "visuals"});

local aimbot_section = combat_tab:Section({
    Name = "aimbot",
    Side = "Left",
    Scrollable = false,
    AutoSize = true, -- will auto resize the canvas if you have scrollable on
    Size = 15 -- only use if scrollable is true or you don't have auto size enabled
})

aimbot_section:Toggle({
    Name = "enabled",
    Flag = "aimbot_enabled",
    SubElements = true,
    Default = false,
    Callback = function(v)
        print(v);     
    end;
}):Colorpicker({Name = "Colorpicker", Flag = "colorpicker_aimbot", Default = Color3.fromRGB(125,51,255)});

aimbot_section:Button({
    Name = "button",
    Callback = function()
        print("Pressed");
    end;
})

aimbot_section:Slider({
    Name = "slider",
    Flag = "aimbot_slider",
    Default = 15,
    Min = 0,
    Max = 100,
    Decimals = 1,
    Sub = "%",
    Infinite = true,
    Callback = function(v)
        print(v);
    end
})

aimbot_section:Dropdown({
    Name = "dropdown",
    Flag = "aimbot_dropdown",
    Options = {"head","torso","penis","foot"};
    Default = "penis",
    Multi = false,
    Callback = function(v)
        --print(v);
    end;
})

aimbot_section:Dropdown({
    Name = "dropdown",
    Flag = "aimbot_dropdown",
    Options = {"head","torso","penis","foot"};
    Default = {"penis", "foot"},
    Multi = true,
    Callback = function(v)
        --print(v);
    end;
})
