local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- oblique strategies printing (from vim-startify)

-- To add this to the footer, simply add the following lines to the config:
-- use {
--     'goolord/alpha-nvim',
--     config = function ()
--         require'alpha.themes.dashboard'.section.footer.val = require'alpha.oblique_strategies'()
--         require'alpha'.setup(require'alpha.themes.dashboard'.opts)
--     end
-- }

local format_line = function(line, max_width)
    -- inserts linebreaks into line
    local formatted_line = "\n"
    if line == '' then
        formatted_line = formatted_line .. " "
        return formatted_line
    end

    -- split line by spaces into list of words
    local words = {}
    local target = "%S+"
    for word in line:gmatch(target) do
        table.insert(words, word)
    end

    local bufstart = ""
    local buffer = bufstart
    for i, word in ipairs(words) do
        if ((#buffer + #word + 1) < max_width) then
            buffer = buffer .. word .. " "
            if (i == #words) then
                formatted_line = formatted_line .. buffer:sub(1,-2) .. "\n"
            end
        else
            formatted_line = formatted_line .. buffer:sub(1,-2) .. "\n"
            buffer = bufstart .. word .. " "
        end
    end

    return formatted_line
end

local format_strategy = function(strategy, max_width)
    -- Converts list of strings to one formatted string (with linebreaks)
    local formatted_strategy = " \n "  -- adds spacing between alpha-menu and footer
    for _, line in ipairs(strategy) do
        local formatted_line = format_line(line, max_width)
        formatted_strategy = formatted_strategy .. formatted_line
    end
    return formatted_strategy
end

local get_strategy = function(strategies_list)
    -- selects an entry from fortune_list randomly
    math.randomseed(os.time())
    local ind = math.random(1, #strategies_list)
    return strategies_list[ind]
end

local oblique_strategies = function()
    local max_width = 54

		local strategies_list = {
			{ "Abandon normal instruments" },
			{ "Accept advice" },
			{ "Accretion" },
			{ "A line has two sides" },
			{ "Allow an easement (an easement is the abandonment of a stricture)" },
			{ "Are there sections? Consider transitions" },
			{ "Ask people to work against their better judgement" },
			{ "Ask your body" },
			{ "Assemble some of the instruments in a group and treat the group" },
			{ "Balance the consistency principle with the inconsistency principle" },
			{ "Be dirty" },
			{ "Breathe more deeply" },
			{ "Bridges -build -burn" },
			{ "Cascades" },
			{ "Change instrument roles" },
			{ "Change nothing and continue with immaculate consistency" },
			{ "Children's voices -speaking -singing" },
			{ "Cluster analysis" },
			{ "Consider different fading systems" },
			{ "Consult other sources -promising -unpromising" },
			{ "Convert a melodic element into a rhythmic element" },
			{ "Courage!" },
			{ "Cut a vital connection" },
			{ "Decorate, decorate" },
			{ "Define an area as `safe' and use it as an anchor" },
			{ "Destroy -nothing -the most important thing" },
			{ "Discard an axiom" },
			{ "Disconnect from desire" },
			{ "Discover the recipes you are using and abandon them" },
			{ "Distorting time" },
			{ "Do nothing for as long as possible" },
			{ "Don't be afraid of things because they're easy to do" },
			{ "Don't be frightened of cliches" },
			{ "Don't be frightened to display your talents" },
			{ "Don't break the silence" },
			{ "Don't stress one thing more than another" },
			{ "Do something boring" },
			{ "Do the washing up" },
			{ "Do the words need changing?" },
			{ "Do we need holes?" },
			{ "Emphasize differences" },
			{ "Emphasize repetitions" },
			{ "Emphasize the flaws" },
			{ "Faced with a choice, do both (given by Dieter Rot)" },
			{ "Feedback recordings into an acoustic situation" },
			{ "Fill every beat with something" },
			{ "Get your neck massaged" },
			{ "Ghost echoes" },
			{ "Give the game away" },
			{ "Give way to your worst impulse" },
			{ "Go slowly all the way round the outside" },
			{ "Honor thy error as a hidden intention" },
			{ "How would you have done it?" },
			{ "Humanize something free of error" },
			{ "Imagine the music as a moving chain or caterpillar" },
			{ "Imagine the music as a set of disconnected events" },
			{ "Infinitesimal gradations" },
			{ "Intentions -credibility of -nobility of -humility of" },
			{ "Into  the impossible" },
			{ "Is it finished?" },
			{ "Is there something missing?" },
			{ "Is the tuning appropriate?" },
			{ "Just carry on" },
			{ "Left channel, right channel, centre channel" },
			{ "Listen in total darkness, or in a very large room, very quietly" },
			{ "Listen to the quiet voice" },
			{ "Look at a very small object, look at its centre" },
			{ "Look at the order in which you do things" },
			{ "Look closely at the most embarrassing details and amplify them" },
			{ "Lowest common denominator check -single beat -single note -single" },
			{ "riff" },
			{ "Make a blank valuable by putting it in an exquisite frame" },
			{ "Make an exhaustive list of everything you might do and do the last thing on the list" },
			{ "Make a sudden, destructive unpredictable action; incorporate" },
			{ "Mechanicalize something idiosyncratic" },
			{ "Mute and continue" },
			{ "Only one element of each kind" },
			{ "(Organic) machinery" },
			{ "Overtly resist change" },
			{ "Put in earplugs" },
			{ "Remember those quiet evenings" },
			{ "Remove ambiguities and convert to specifics" },
			{ "Remove specifics and convert to ambiguities" },
			{ "Repetition is a form of change" },
			{ "Reverse" },
			{ "Short circuit (example: a man eating peas with the idea that they will improve his virility shovels them straight into his lap)" },
			{ "Shut the door and listen from outside" },
			{ "Simple subtraction" },
			{ "Spectrum analysis" },
			{ "Take a break" },
			{ "Take away the elements in order of apparent non-importance" },
			{ "Tape your mouth (given by Ritva Saarikko)" },
			{ "The inconsistency principle" },
			{ "The tape is now the music" },
			{ "Think of the radio" },
			{ "Tidy up" },
			{ "Trust in the you of now" },
			{ "Turn it upside down" },
			{ "Twist the spine" },
			{ "Use an old idea" },
			{ "Use an unacceptable color" },
			{ "Use fewer notes" },
			{ "Use filters" },
			{ "Use \"unqualified\" people" },
			{ "Water" },
			{ "What are you really thinking about just now? Incorporate" },
			{ "What is the reality of the situation?" },
			{ "What mistakes did you make last time?" },
			{ "What would your closest friend do?" },
			{ "What wouldn't you do?" },
			{ "Work at a different speed" },
			{ "You are an engineer" },
			{ "You can only make one dot at a time" },
			{ "You don't have to be ashamed of using your own ideas" },
			{ "[blank white card]" },
	}

	local strategy = get_strategy(strategies_list)
	local formatted_strategy = format_strategy(strategy, max_width)

	return formatted_strategy
end

local install_info = function ()
    local datetime = os.date "%d-%m-%Y %H:%M:%S"
    return " " .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch .. "   " .. datetime
end

dashboard.section.header.val = oblique_strategies()
dashboard.section.buttons.val = {
	dashboard.button( "f", "  > Find file", ":cd $HOME | Telescope find_files<CR>"),
	dashboard.button( "r", "  > Recent"   , ":Telescope oldfiles<CR>"),
	dashboard.button( "s", "  > Settings" , ":e $MYVIMRC<CR>"),
	dashboard.button( "p", "↺  > Sync packages", ":PackerSync<CR>"),
	dashboard.button( "q", "  > Quit NVIM", ":qa<CR>"),
	-- TODO: this obvs won't work, how could I make it work?
	-- dashboard.button( "x", "∀  > New strategy", ":lua strategy()<CR>"),
}
dashboard.section.footer.val = install_info()

alpha.setup(dashboard.opts)
