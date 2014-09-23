package com.bit101.components.treeView
{
    /**
     * @history create 15.09.14 15:16
     * @author Sergey Smirnov
     */
    public class TreeViewNode
    {
        //------------------------------------------------
        //      Class constants
        //------------------------------------------------

        //------------------------------------------------
        //      Variables
        //------------------------------------------------

        private var _index:int;
        private var _name:String;
        private var _tag:String;
        private var _root:TreeViewNode;
        private var _parent:TreeViewNode;
        private var _children:Vector.<TreeViewNode>;
        private var _isExpanded:Boolean;
        private var _indent:int;

        //---------------------------------------------------------------
        //
        //      CONSTRUCTOR
        //
        //---------------------------------------------------------------

        public function TreeViewNode()
        {
            init();
        }

        //---------------------------------------------------------------
        //
        //      PRIVATE & PROTECTED METHODS
        //
        //---------------------------------------------------------------

        protected function init():void
        {
            _index = 0;
            _name = "";
            _tag = "";
            _root = this;
            _parent = null;
            _children = new <TreeViewNode>[];
            _isExpanded = false;
            _indent = 0;
        }

        protected function updateIndent():void
        {
            if (!_parent)
            {
                return;
            }

            _indent = _parent.indent + 1;
        }

        //---------------------------------------------------------------
        //
        //      EVENT HANDLERS
        //
        //---------------------------------------------------------------

        public function onAddedInHierarchy():void
        {
            //
        }

        //---------------------------------------------------------------
        //
        //      PUBLIC METHODS
        //
        //---------------------------------------------------------------

        public function updateFromObject(data:Object):void
        {
            _name = data.name ? data.name : "";
            _tag = data.tag ? data.tag : "";
        }

        public function updateIndents():void
        {
            updateIndent();

            for each (var childNode:TreeViewNode in _children)
            {
                childNode.updateIndents();
            }
        }

        /**
         * Add passed node as child.
         *
         * @param node
         */
        public function addNode(node:TreeViewNode):void
        {
            if (node.parent)
            {
                node.parent.removeNode(node);
            }

            node.root = this.root;
            node.parent = this;
            _children.push(node);
            updateNodesIndex();
            expand();

            node.onAddedInHierarchy();
        }

        public function addNodeAt(node:TreeViewNode, index:int):void
        {
            if (node.parent)
            {
                node.parent.removeNode(node);
            }

            node.root = this.root;
            node.parent = this;

            _children.splice(index, 0, node);
            updateNodesIndex();

            node.onAddedInHierarchy();
        }

        protected function updateNodesIndex():void
        {
            var i:int = 0;
            var node:TreeViewNode;

            while (i < _children.length)
            {
                node = _children[i];
                node.index = i;

                i++;
            }
        }

        /**
         * Removes passed child node.
         *
         * @param node - child node
         */
        public function removeNode(node:TreeViewNode):void
        {
            var nodeIndex:int = _children.indexOf(node);

            if (nodeIndex < 0)
            {
                return;
            }

            node.root = null;
            node.parent = null;
            node.index = 0;

            _children.splice(nodeIndex, 1);
            updateNodesIndex();
        }

        /**
         * Expand current node.
         */
        public function expand():Boolean
        {
            if (isExpanded || children.length <= 0)
            {
                return false;
            }

            _isExpanded = true;
            return true;
        }

        /**
         * Expand all nodes in hierarchy.
         */
        public function expandAll():Boolean
        {
            var wasExpanded:Boolean = expand();
            var childWasExpanded:Boolean = false;

            for each (var childNode:TreeViewNode in _children)
            {
                childWasExpanded = childNode.expandAll();

                if (childWasExpanded && !wasExpanded)
                {
                    wasExpanded = childWasExpanded;
                }
            }

            return wasExpanded;
        }

        /**
         * Collapse current node.
         */
        public function collapse():Boolean
        {
            if (!isExpanded || children.length <= 0)
            {
                return false;
            }

            _isExpanded = false;
            return true;
        }

        /**
         * Collapse all nodes in hierarchy.
         */
        public function collapseAll():Boolean
        {
            var wasCollapsed:Boolean = collapse();
            var childWasCollapsed:Boolean = false;

            for each (var childNode:TreeViewNode in _children)
            {
                childWasCollapsed = childNode.collapseAll();

                if (childWasCollapsed && !wasCollapsed)
                {
                    wasCollapsed = childWasCollapsed;
                }
            }

            return wasCollapsed;
        }

        /**
         * Find child node by index.
         *
         * @param nodeIndex - index of node
         * @return TreeViewNode
         */
        public function getNodeAt(nodeIndex:int):TreeViewNode
        {
            return _children[nodeIndex];
        }

        /**
         * Find first child node with passed name.
         *
         * @param nodeName - name of node
         * @return TreeViewNode
         */
        public function getChildNodeByName(nodeName:String):TreeViewNode
        {
            var i:int = 0;
            var childNode:TreeViewNode;

            while (i < _children.length)
            {
                childNode = _children[i];

                if (childNode.name == nodeName)
                {
                    return childNode;
                }

                i++;
            }

            return null;
        }

        /**
         * Find first child node in hierarchy with passed property.
         *
         * @param propertyName - name of node property
         * @param propertyValue - value of node property
         * @return TreeViewNode
         */
        public function getChildNodeByProperty(propertyName:String, propertyValue:Object):TreeViewNode
        {
            var i:int = 0;
            var childNode:TreeViewNode;

            while (i < _children.length)
            {
                childNode = _children[i];

                if (childNode[propertyName] && childNode[propertyName] == propertyValue)
                {
                    return childNode;
                }

                i++;
            }

            return null;
        }

        /**
         * Find first child node with passed tag.
         *
         * @param nodeTag - tag of node
         * @return TreeViewNode
         */
        public function getChildNodeByTag(nodeTag:String):TreeViewNode
        {
            var i:int = 0;
            var childNode:TreeViewNode;

            while (i < _children.length)
            {
                childNode = _children[i];

                if (childNode.tag == nodeTag)
                {
                    return childNode;
                }

                i++;
            }

            return null;
        }

        /**
         * Find all child nodes with passed name.
         *
         * @param nodeName - tag of node
         * @return Vector.<TreeViewNode>
         */
        public function getChildNodesByName(nodeName:String):Vector.<TreeViewNode>
        {
            var i:int = 0;
            var result:Vector.<TreeViewNode> = new <TreeViewNode>[];
            var childNode:TreeViewNode;

            while (i < _children.length)
            {
                childNode = _children[i];

                if (childNode.name == nodeName)
                {
                    result.push(childNode);
                }

                i++;
            }

            return result;
        }

        /**
         * Find all child nodes with passed tag.
         *
         * @param nodeTag - tag of node
         * @return Vector.<TreeViewNode>
         */
        public function getChildNodesByTag(nodeTag:String):Vector.<TreeViewNode>
        {
            var i:int = 0;
            var result:Vector.<TreeViewNode> = new <TreeViewNode>[];
            var childNode:TreeViewNode;

            while (i < _children.length)
            {
                childNode = _children[i];

                if (childNode.tag == nodeTag)
                {
                    result.push(childNode);
                }

                i++;
            }

            return result;
        }

        /**
         * Find first child node in hierarchy with passed name.
         *
         * @param nodeName - tag of node
         * @return TreeViewNode
         */
        public function findNodeByName(nodeName:String):TreeViewNode
        {
            var i:int = 0;
            var childNode:TreeViewNode;
            var result:TreeViewNode = getChildNodeByName(nodeName);

            while (i < _children.length && !result)
            {
                childNode = _children[i];
                result = childNode.findNodeByName(nodeName);

                i++;
            }

            return result;
        }

        /**
         * Find first node in hierarchy with passed property.
         *
         * @param propertyName - name of node property
         * @param propertyValue - value of node property
         * @return TreeViewNode
         */
        public function findNodeByProperty(propertyName:String, propertyValue:Object):TreeViewNode
        {
            var i:int = 0;
            var childNode:TreeViewNode;
            var result:TreeViewNode = getChildNodeByProperty(propertyName, propertyValue);

            while (i < _children.length && !result)
            {
                childNode = _children[i];
                result = childNode.findNodeByProperty(propertyName, propertyValue);

                i++;
            }

            return result;
        }

        /**
         * Find all child nodes in hierarchy with passed name.
         *
         * @param nodeName - tag of node
         * @return Vector.<TreeViewNode>
         */
        public function findNodesByName(nodeName:String):Vector.<TreeViewNode>
        {
            var i:int = 0;
            var result:Vector.<TreeViewNode> = getChildNodesByName(nodeName);
            var childNode:TreeViewNode;

            while (i < _children.length)
            {
                childNode = _children[i];
                result = result.concat(childNode.findNodesByName(nodeName));

                i++;
            }

            return result;
        }

        /**
         * Find first child node in hierarchy with passed tag.
         *
         * @param nodeTag - tag of node
         * @return TreeViewNode
         */
        public function findNodeByTag(nodeTag:String):TreeViewNode
        {
            var i:int = 0;
            var childNode:TreeViewNode;
            var result:TreeViewNode = getChildNodeByTag(nodeTag);

            while (i < _children.length && !result)
            {
                childNode = _children[i];
                result = childNode.findNodeByTag(nodeTag);

                i++;
            }

            return result;
        }

        /**
         * Find all child nodes in hierarchy with passed tag.
         *
         * @param nodeTag - tag of node
         * @return Vector.<TreeViewNode>
         */
        public function findNodesByTag(nodeTag:String):Vector.<TreeViewNode>
        {
            var i:int = 0;
            var result:Vector.<TreeViewNode> = getChildNodesByTag(nodeTag);
            var childNode:TreeViewNode;

            while (i < _children.length)
            {
                childNode = _children[i];
                result = result.concat(childNode.findNodesByTag(nodeTag));

                i++;
            }

            return result;
        }

        public function update():void
        {
            for each (var childNode:TreeViewNode in children)
            {
                childNode.update();
            }
        }

        /**
         * Dispose the node.
         */
        public function dispose():void
        {
            _name = null;
            _tag = null;
            _children = null;
        }

        //---------------------------------------------------------------
        //
        //      ACCESSORS
        //
        //---------------------------------------------------------------

        public function get index():int
        {
            return _index;
        }

        public function set index(value:int):void
        {
            _index = value;
        }

        public function get name():String
        {
            return _name;
        }

        public function set name(value:String):void
        {
            _name = value;
        }

        public function get tag():String
        {
            return _tag;
        }

        public function set tag(value:String):void
        {
            _tag = value;
        }

        public function get root():TreeViewNode
        {
            return _root;
        }

        public function set root(value:TreeViewNode):void
        {
            _root = value;
        }

        public function get parent():TreeViewNode
        {
            return _parent;
        }

        public function set parent(value:TreeViewNode):void
        {
            _parent = value;
        }

        public function get children():Vector.<TreeViewNode>
        {
            return _children;
        }

        public function get isRoot():Boolean
        {
            return parent == null;
        }

        public function get isExpanded():Boolean
        {
            return _isExpanded;
        }

        public function get indent():int
        {
            return _indent;
        }
    }
}
