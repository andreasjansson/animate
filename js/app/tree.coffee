class Tree
    constructor: ->
        @root = null
        @index = {}

    find: (key) ->
        if key of @index
            return @index[key].value
        return null

    insert: (key, value) ->
        node = new TreeNode(key, value)
        if @root?
            node = @root.insert(node)
        else
            @root = node
        @index[key] = node

    delete: (key) ->
        if key of @index
            [node, replacement] = @root.delete(key)
            if node == @root
                @root = replacement
            delete @index[key]
            return node.value
        return null

    size: ->
        if @root?
            return @root.size()
        return 0

    iterator: (key=null) ->
        if @root?
            if key
                current = @index[key]
            return new TreeIterator(@root, current)
        throw Error('Cannot iterate over empty tree')

class TreeIterator
    constructor: (root, current) ->
        @_begin = root.begin()
        @_end = root.end()
        if current
            @_current = current
        else
            @_current = @_begin

    next: ->
        @_current = @_current.next
        return @

    prev: ->
        @_current = @_current.prev
        return @

    current: ->
        return key: @_current.key, value: @_current.value

    hasNext: ->
        return @_current.next?

    hasPrev: ->
        return @_current.prev?

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
            return @
        if key < @key and @left?
            return @left.find(key)
        if @right?
            return @right.find(key)
        return null

    insert: (node) ->

        if node.key == @key
            @value = node.value
            return @

        if node.key < @key
            if @left?
                return @left.insert(node)

            else
                if @prev
                    node.prev = @prev
                    @prev.next = node

                node.next = @
                @prev = node

                node.parent = @
                @left = node

        else
            if @right?
                return @right.insert(node)

            else
                if @next
                    node.next = @next
                    @next.prev = node

                node.prev = @
                @next = node

                node.parent = @
                @right = node

        return node

    delete: (key) ->
        node = @find(key)

        if not node?
            return [null, null]

        if node.prev
            node.prev.next = node.next
        if node.next
            node.next.prev = node.prev

        if node.left? and node.right?
            # randomly select either the successor or the predecessor
            if Math.random() < .5
                replacement = node.left.end()
            else
                replacement = node.right.begin()

            newChild = replacement.left or replacement.right
            if replacement.parent.left == replacement
                replacement.parent.left = newChild
            else
                replacement.parent.right = newChild
            if newChild
                newChild.parent = replacement.parent

            replacement.left = node.left
            replacement.right = node.right

            if replacement.left
                replacement.left.parent = replacement
            if replacement.right
                replacement.right.parent = replacement

        else
            replacement = node.left or node.right

        if replacement
            replacement.parent = node.parent
        if node.parent?
            if node.parent.left == node
                node.parent.left = replacement
            else
                node.parent.right = replacement

        return [node, replacement]

    begin: ->
        if @left?
            return @left.begin()
        return @

    end: ->
        if @right?
            return @right.end()
        return @

    depth: ->
        leftDepth = if @left? then @left.depth() else 0
        rightDepth = if @right? then @right.depth() else 0
        return 1 + Math.max(leftDepth, rightDepth)

    size: ->
        leftSize = if @left? then @left.size() else 0
        rightSize = if @right? then @right.size() else 0
        return 1 + leftSize + rightSize

if exports?
    exports.Tree = Tree
    exports.TreeIterator = TreeIterator
    exports.TreeNode = TreeNode
 
