jasmine = require('jasmine-node')
tree = require('./../app/model/tree')
TreeNode = tree.TreeNode
Tree = tree.Tree

describe 'tree.js', ->

    beforeEach ->
        @a = new TreeNode(0, 'a')
        @b = new TreeNode(1, 'b')
        @c = new TreeNode(2, 'c')
        @d = new TreeNode(3, 'd')
        @e = new TreeNode(4, 'e')
        @f = new TreeNode(5, 'f')
        @g = new TreeNode(6, 'g')
        @h = new TreeNode(7, 'h')
        @i = new TreeNode(8, 'i')
        @j = new TreeNode(9, 'j')

    it 'creates a simple tree', ->
        node = new TreeNode(10, 'a')
        expect(node.depth()).toEqual(1)

    it 'inserts a few nodes', ->
        @f.insert(@d)
        expect(@f.left).toEqual(@d)
        expect(@d.next).toEqual(@f)
        expect(@f.prev).toEqual(@d)
        expect(@d.parent).toEqual(@f)

        @f.insert(@e)
        expect(@f.left).toEqual(@d)
        expect(@d.right).toEqual(@e)
        expect(@d.next).toEqual(@e)
        expect(@e.prev).toEqual(@d)
        expect(@e.next).toEqual(@f)
        expect(@f.prev).toEqual(@e)

        @f.insert(@c)
        expect(@f.left).toEqual(@d)
        expect(@d.parent).toEqual(@f)
        expect(@d.left).toEqual(@c)
        expect(@c.parent).toEqual(@d)
        expect(@d.right).toEqual(@e)
        expect(@e.parent).toEqual(@d)
        expect(@c.next).toEqual(@d)
        expect(@d.prev).toEqual(@c)
        expect(@d.next).toEqual(@e)
        expect(@e.prev).toEqual(@d)
        expect(@e.next).toEqual(@f)
        expect(@f.prev).toEqual(@e)

    it 'reports the correct size', ->
        expect(@a.size()).toEqual(1)
        @a.insert(@f)
        expect(@a.size()).toEqual(2)
        @a.insert(@c)
        expect(@a.size()).toEqual(3)
        @a.insert(@d)
        expect(@a.size()).toEqual(4)
        @a.insert(@h)
        expect(@a.size()).toEqual(5)
        @a.insert(@i)
        expect(@a.size()).toEqual(6)
        @a.insert(@b)
        expect(@a.size()).toEqual(7)

    it 'deletes a left node with no children', ->
        @f.insert(@d)
        expect(@f.depth()).toEqual(2)
        expect(@f.delete(3)).toEqual([@d, null])
        expect(@f.depth()).toEqual(1)
        
    it 'deletes a right node with no children', ->
        @f.insert(@h)
        expect(@f.depth()).toEqual(2)
        expect(@f.delete(7)).toEqual([@h, null])
        expect(@f.depth()).toEqual(1)

    it 'deletes a left node with a right child', ->        
        @f.insert(@d)
        @f.insert(@e)
        expect(@f.depth()).toEqual(3)
        expect(@f.delete(3)).toEqual([@d, @e])
        expect(@f.depth()).toEqual(2)
        expect(@f.left).toEqual(@e)
        expect(@e.parent).toEqual(@f)
        expect(@e.next).toEqual(@f)
        expect(@f.prev).toEqual(@e)

    it 'deletes a left node with a left child', ->
        @f.insert(@d)
        @f.insert(@c)
        expect(@f.depth()).toEqual(3)
        expect(@f.delete(3)).toEqual([@d, @c])
        expect(@f.depth()).toEqual(2)
        expect(@f.left).toEqual(@c)
        expect(@c.parent).toEqual(@f)
        expect(@c.next).toEqual(@f)
        expect(@f.prev).toEqual(@c)

    it 'deletes a right node with a left child', ->
        @f.insert(@h)
        @f.insert(@g)
        expect(@f.depth()).toEqual(3)
        expect(@f.delete(7)).toEqual([@h, @g])
        expect(@f.depth()).toEqual(2)
        expect(@f.right).toEqual(@g)
        expect(@g.parent).toEqual(@f)
        expect(@f.next).toEqual(@g)
        expect(@g.prev).toEqual(@f)

    it 'deletes a left node with two children', ->
        @f.insert(@d)
        @f.insert(@c)
        @f.insert(@e)
        expect(@f.depth()).toEqual(3)
        [node, replacement] = @f.delete(3)
        expect(node).toEqual(@d)
        expect(replacement.parent).toEqual(@f)
        expect(@f.left).toEqual(replacement)
        if replacement == @c
            expect(@c.right).toEqual(@e)
            expect(@e.parent).toEqual(@c)
        else if replacement == @e
            expect(@e.left).toEqual(@c)
            expect(@c.parent).toEqual(@e)
        else
            fail()
        expect(@c.next).toEqual(@e)
        expect(@e.next).toEqual(@f)

    it 'deletes a right node with two subtrees', ->
        @a.insert(@f)
        @a.insert(@d)
        @a.insert(@c)
        @a.insert(@e)
        @a.insert(@h)
        @a.insert(@g)
        @a.insert(@i)

        expect(@a.depth()).toEqual(4)
        [node, replacement] = @a.delete(5)
        expect(node).toEqual(@f)
        expect(replacement.parent).toEqual(@a)
        expect(@a.right).toEqual(replacement)
        if replacement == @e
            expect(@e.left).toEqual(@d)
            expect(@d.parent).toEqual(@e)
            expect(@e.right).toEqual(@h)
            expect(@h.parent).toEqual(@e)
        else if replacement == @g
            expect(@g.left).toEqual(@d)
            expect(@d.parent).toEqual(@g)
            expect(@g.right).toEqual(@h)
            expect(@h.parent).toEqual(@g)
        else
            fail()

        expect(@a.next).toEqual(@c)
        expect(@c.next).toEqual(@d)
        expect(@d.next).toEqual(@e)
        expect(@e.next).toEqual(@g)
        expect(@g.next).toEqual(@h)
        expect(@h.next).toEqual(@i)
        expect(@i.next).toEqual(null)

    it 'iterates in the right order, even when deleting', ->
        for i in [0..9]
            list = (Math.random() for j in [0..99])
            tree = new Tree()
            for x in list
                tree.insert(x, x)

            for k in [0..9]
                indexToRemove = Math.floor(Math.random() * list.length)
                keyToRemove = list.splice(indexToRemove, 1)[0]
                removed = tree.delete(keyToRemove)
                expect(removed).toEqual(keyToRemove)
                expect(tree.size()).toEqual(list.length)

                sorted_list = list.slice(0)
                sorted_list.sort()

                it = tree.iterator()
                i = 0
                while it.hasNext()
                    expect(it.current().key).toEqual(sorted_list[i])
                    i += 1
                    it.next()

                while it.hasPrev()
                    expect(it.current().key).toEqual(sorted_list[i])
                    i -= 1
                    it.prev()
