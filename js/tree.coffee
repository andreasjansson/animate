tree = ->

    class TreeNode

        constructor: (key, value) ->
            @key = key
            @value = value
            @left = null
            @right = null
            @prev = null
            @next = null
            @parent = null

        find: (key) ->
            if key == @key
                return @value
            if key < @key and @left?
                return @left.find(key)
            if @right?
                return @right.find(key)
            return null

        insert: (key, value) ->

            if key == @key:
                @value = value

            else if key < @key:
                if @left?
                    @left.insert(key, value)

                else
                    node = new TreeNode(key, value)

                    node.prev = @prev
                    @prev.next = node

                    node.next = @
                    @prev = node

                    node.parent = @
                    @left = node

            else
                if @right?
                    @right.insert(key, value)

                else
                    node = new TreeNode(key, value)

                    node.next = @next
                    @next.prev = node

                    node.prev = @
                    @next = node

                    node.parent = @
                    @right = node
                
