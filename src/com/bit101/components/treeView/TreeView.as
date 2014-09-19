package com.bit101.components.treeView
{
    import com.bit101.components.ScrollPane;
    import com.bit101.components.Style;
    import com.bit101.components.VBox;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;

    /**
     * @history create 15.09.14 14:59
     * @author Sergey Smirnov
     */
    public class TreeView extends ScrollPane
    {
        //------------------------------------------------
        //      Class constants
        //------------------------------------------------

        //------------------------------------------------
        //      Variables
        //------------------------------------------------

        protected var _data:Object;
        protected var _rootNode:TreeViewNode;
        protected var _group:VBox;
        protected var _activeNodes:Vector.<TreeViewNode>;
        protected var _inactiveItems:Vector.<TreeViewItem>;
        protected var _itemClass:Class;
        protected var _itemHeight:int;
        protected var _canMultiSelect:Boolean;
        protected var _allowMultiSelection:Boolean;
        protected var _selectedItems:Vector.<TreeViewItem>;
        protected var _multiSelectionKeyCodes:Vector.<uint>;
        protected var _alternateRows:Boolean;
        protected var _highlightOnHover:Boolean;
        protected var _selectable:Boolean;

        // colors
        protected var _defaultColor:uint;
        protected var _alternateColor:uint;
        protected var _selectedColor:uint;
        protected var _rolloverColor:uint;
        //

        //---------------------------------------------------------------
        //
        //      CONSTRUCTOR
        //
        //---------------------------------------------------------------

        public function TreeView(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
        {
            _itemClass = TreeViewItem;
            _itemHeight = 20;
            _allowMultiSelection = false;
            _canMultiSelect = false;
            _selectedItems = new <TreeViewItem>[];
            _multiSelectionKeyCodes = new <uint>[Keyboard.CONTROL, Keyboard.COMMAND];
            _alternateRows = false;
            _highlightOnHover = true;
            _selectable = true;

            // init colors
            _defaultColor = Style.LIST_DEFAULT;
            _alternateColor = Style.LIST_ALTERNATE;
            _selectedColor = Style.LIST_SELECTED;
            _rolloverColor = Style.LIST_ROLLOVER;
            //

            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

            super(parent, xpos, ypos);
        }

        //---------------------------------------------------------------
        //
        //      PRIVATE & PROTECTED METHODS
        //
        //---------------------------------------------------------------

        /**
         * @inheritDoc
         */
        override protected function init():void
        {
            super.init();

            this.dragContent = false;
            this.autoHideScrollBar = true;
            setSize(200, 400);

            _rootNode = getNodeFrom({name: "Root"});

            _activeNodes = new <TreeViewNode>[];
            _inactiveItems = new <TreeViewItem>[];

            initEventListeners();
        }

        protected function disposeAllActiveItems():void
        {
            var item:TreeViewItem;

            while (_group.numChildren > 0)
            {
                item = TreeViewItem(_group.getChildAt(0));
                _group.removeChild(item);
                item.dispose();
            }
        }

        protected function disposeAllInactiveItems():void
        {
            var item:TreeViewItem;

            while (_inactiveItems.length > 0)
            {
                item = _inactiveItems[0];
                item.dispose();
            }
        }

        protected function disposeNodeHierarchy(node:TreeViewNode):void
        {
            var item:TreeViewItem;

            for each (var childNode:TreeViewNode in node)
            {
                disposeNodeHierarchy(childNode);
            }

            node.dispose();
        }

        protected function initEventListeners():void
        {

        }

        protected function removeEventListeners():void
        {

        }

        /**
         * @inheritDoc
         */
        override protected function addChildren():void
        {
            super.addChildren();
            _group = createGroup();
        }

        protected function createGroup():VBox
        {
            var result:VBox = new VBox(content);
            result.spacing = 0;

            return result;
        }

        protected function processData():void
        {
            _rootNode = processNodeData(_data);
        }

        protected function getNodeFrom(data:Object):TreeViewNode
        {
            var result:TreeViewNode = new TreeViewNode();
            result.name = data.name ? data.name : "";
            result.tag = data.tag ? data.tag : "";

            return result;
        }

        protected function processNodeData(data:Object):TreeViewNode
        {
            var result:TreeViewNode = getNodeFrom(data);

            if (!data.children)
            {
                return result;
            }

            for each (var childData:Object in data.children)
            {
                var childNode:TreeViewNode = processNodeData(childData);
                result.addNode(childNode);
            }

            return result;
        }

        protected function processView():void
        {
            _rootNode.updateIndents();
            _activeNodes = new <TreeViewNode>[];

            deactivateItems();
            processNode(_rootNode);
            displayItems();
            removeUnusedItems();
        }

        protected function deactivateItems():void
        {
            var item:TreeViewItem;

            for (var i:int = 0; i < _group.numChildren; i++)
            {
                item = TreeViewItem(_group.getChildAt(i));
                item.removeEventListener(MouseEvent.CLICK, onItemClick);
                item.onDeactivate();
            }
        }

        protected function processNode(node:TreeViewNode):void
        {
            for each (var childNode:TreeViewNode in node.children)
            {
                _activeNodes.push(childNode);

                if (childNode.isExpanded)
                {
                    processNode(childNode);
                }
            }
        }

        protected function removeUnusedItems():void
        {
            if (_group.numChildren <= 0)
            {
                return;
            }

            var item:TreeViewItem;

            if (_activeNodes.length >= _group.numChildren)
            {
                return;
            }

            while (_group.numChildren > _activeNodes.length)
            {
                item = TreeViewItem(_group.removeChildAt(_group.numChildren - 1));
                _inactiveItems.push(item);
            }
        }

        protected function displayItems():void
        {
            var item:TreeViewItem;
            var childNode:TreeViewNode;

            for (var i:int = 0; i < _activeNodes.length; i++)
            {
                childNode = _activeNodes[i];
                item = createItem(i);
                item.highlightOnHover = highlightOnHover;

                calculateItemColors(item, i);
                calculateItemSize(item);

                item.node = childNode;

                if (!_group.contains(item))
                {
                    _group.addChild(item);
                }

                item.onActivate();

                if (selectable)
                {
                    item.addEventListener(MouseEvent.CLICK, onItemClick);
                }
                else
                {
                    item.removeEventListener(MouseEvent.CLICK, onItemClick);
                }
            }
        }

        protected function calculateItemColors(item:TreeViewItem, index:int):void
        {
            if (alternateRows && index % 2 == 0)
            {
                item.defaultColor = alternateColor;
            }
            else
            {
                item.defaultColor = defaultColor;
            }

            item.selectedColor = selectedColor;
            item.rolloverColor = rolloverColor;
        }

        protected function calculateItemSize(item:TreeViewItem):void
        {
            var vSrollWidth:Number = _vScrollbar.visible ? _vScrollbar.width : 0.0;
            item.setSize(width - vSrollWidth, _itemHeight);
        }

        protected function createItem(index:int):TreeViewItem
        {
            var result:TreeViewItem;

            if (index < _group.numChildren)
            {
                result = TreeViewItem(_group.getChildAt(index));
            }
            else
            {
                if (_inactiveItems.length > 0)
                {
                    result = _inactiveItems.shift();
                }
                else
                {
                    result = new _itemClass(this, null);
                }
            }

            return result;
        }

        protected function updateMultiSelectionState():void
        {
            if (!this.stage)
            {
                return;
            }

            if (_allowMultiSelection)
            {
                this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
                this.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            }
            else
            {
                this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
                this.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            }

            if (_selectedItems.length > 1)
            {
                unselectAll();
            }
        }

        protected function selectItem(item:TreeViewItem):void
        {
            if (!_canMultiSelect && _selectedItems.length > 0)
            {
                unselectAll();
            }
            else if (item.isSelected && _canMultiSelect)
            {
                unselectItem(item);
                return;
            }

            _selectedItems.push(item);
            item.select();
        }

        protected function unselectItem(item:TreeViewItem):void
        {
            item.unselect();

            var index:int = _selectedItems.indexOf(item);

            if (index >= 0)
            {
                _selectedItems.splice(index, 1);
            }
        }

        protected function getItemByNode(node:TreeViewNode):TreeViewItem
        {
            var i:int = 0;
            var item:TreeViewItem;

            while (i < _group.numChildren)
            {
                item = TreeViewItem(_group.getChildAt(i));

                if (item.node === node)
                {
                    return item;
                }

                i++;
            }

            return null;
        }

        protected function expandParentHierarchy(node:TreeViewNode):Boolean
        {
            var result:Boolean = false;
            var nodeWasExpanded:Boolean = false;

            while (node.parent)
            {
                node = node.parent;
                nodeWasExpanded = node.expand();

                if (nodeWasExpanded && !result)
                {
                    result = nodeWasExpanded;
                }
            }

            return result;
        }

        //---------------------------------------------------------------
        //
        //      EVENT HANDLERS
        //
        //---------------------------------------------------------------

        protected function onAddedToStage(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            updateMultiSelectionState();
        }

        private function onItemClick(event:MouseEvent):void
        {
            var item:TreeViewItem = TreeViewItem(event.currentTarget);
            selectItem(item);
        }

        protected function onKeyDown(event:KeyboardEvent):void
        {
            if (_multiSelectionKeyCodes.indexOf(event.keyCode) >= 0)
            {
                _canMultiSelect = true;
            }
        }

        protected function onKeyUp(event:KeyboardEvent):void
        {
            if (_multiSelectionKeyCodes.indexOf(event.keyCode) >= 0)
            {
                _canMultiSelect = false;
            }
        }

        //---------------------------------------------------------------
        //
        //      PUBLIC METHODS
        //
        //---------------------------------------------------------------

        /**
         * @inheritDoc
         */
        override public function draw():void
        {
            super.draw();
            refresh();
        }

        /**
         * Select all visible items.
         */
        public function selectAll():void
        {
            if (!_allowMultiSelection)
            {
                return;
            }

            var item:TreeViewItem;

            for (var i:int = 0; i < _group.numChildren; i++)
            {
                item = TreeViewItem(_group.getChildAt(i));
                var index:int = _selectedItems.indexOf(item);

                if (index >= 0)
                {
                    continue;
                }

                item.select();
                _selectedItems.push(item);
            }
        }

        /**
         * Unselect all visible items.
         */
        public function unselectAll():void
        {
            var item:TreeViewItem;

            for (var i:int = 0; i < _group.numChildren; i++)
            {
                item = TreeViewItem(_group.getChildAt(i));
                unselectItem(item);
            }
        }

        /**
         * Expands all nodes in hierarchy.
         */
        public function expandAll():void
        {
            var needRefresh:Boolean = _rootNode.expandAll();

            if (!needRefresh)
            {
                return;
            }

            invalidate();
        }

        /**
         * Collapse all nodes in hierarchy.
         */
        public function collapseAll():void
        {
            var needRefresh:Boolean = _rootNode.collapseAll();

            if (!needRefresh)
            {
                return;
            }

            invalidate();
        }

        /**
         * Find first child node in hierarchy with passed name.
         *
         * @param nodeName - tag of node
         * @return TreeViewNode
         */
        public function findNodeByName(name:String):TreeViewNode
        {
            return _rootNode.findNodeByName(name);
        }

        /**
         * Find all child nodes in hierarchy with passed name.
         *
         * @param nodeName - tag of node
         * @return Vector.<TreeViewNode>
         */
        public function findNodesByName(name:String):Vector.<TreeViewNode>
        {
            return _rootNode.findNodesByName(name);
        }

        /**
         * Find first child node in hierarchy with passed tag.
         *
         * @param nodeTag - tag of node
         * @return TreeViewNode
         */
        public function findNodeByTag(tag:String):TreeViewNode
        {
            return _rootNode.findNodeByTag(tag);
        }

        /**
         * Find all child nodes in hierarchy with passed tag.
         *
         * @param nodeTag - tag of node
         * @return Vector.<TreeViewNode>
         */
        public function findNodesByTag(tag:String):Vector.<TreeViewNode>
        {
            return _rootNode.findNodesByTag(tag);
        }

        /**
         * Select passed node and expand parent hierarchy.
         *
         * @param node - node to select
         */
        public function selectNode(node:TreeViewNode):void
        {
            var needRefresh:Boolean = expandParentHierarchy(node);
            var item:TreeViewItem;

            if (needRefresh)
            {
                refresh();
            }

            item = getItemByNode(node);
            selectItem(item);
        }

        /**
         * Select passed nodes and expand parent hierarchy.
         * If allowMultiselection is false, that will be selected only one node.
         *
         * @param nodes - nodes to select
         */
        public function selectNodes(nodes:Vector.<TreeViewNode>):void
        {
            if (nodes.length <= 0)
            {
                return;
            }

            if (!_allowMultiSelection)
            {
                selectNode(nodes[0]);
                return;
            }

            for each (var node:TreeViewNode in nodes)
            {
                selectNode(node);
            }
        }

        /**
         * Refresh the tree view.
         */
        public function refresh():void
        {
            processView();
        }

        /**
         * Dispose tree view.
         */
        public function dispose():void
        {
            removeEventListeners();
            disposeAllActiveItems();
            disposeAllInactiveItems();
            disposeNodeHierarchy(_rootNode);

            content.removeChild(_group);

            _itemClass = null;
            _group = null;
            _data = null;
            _inactiveItems = null;
            _activeNodes = null;
            _multiSelectionKeyCodes = null;
            _selectedItems = null;
        }

        //---------------------------------------------------------------
        //
        //      ACCESSORS
        //
        //---------------------------------------------------------------

        /**
         * Tree view raw data.
         * For example,
         *
         * {
         *      name: "RootName",
         *      tag: "RootTag",
         *      children:
         *      [
         *          {name: "Child 1", tag: "Child 1"},
         *          {name: "Child 2", tag: "Child 2"},
         *          {name: "Child 3", tag: "Child 3"},
         *          {name: "Child 4", tag: "Child 4", children:
         *          [
         *              {name: "Sub Child 1", tag: "Sub Child 1"},
         *              {name: "Sub Child 2", tag: "Sub Child 2"},
         *              {name: "Sub Child 3", tag: "Sub Child 3"},
         *          ]}
         *      ]
         * }
         *
         */
        public function get data():Object
        {
            return _data;
        }

        public function set data(value:Object):void
        {
            disposeNodeHierarchy(_rootNode);

            _data = value;

            if (!_data)
            {
                return;
            }

            processData();
            invalidate();
        }

        /**
         * Custom subclass of TreeViewItem.
         */
        public function get itemClass():Class
        {
            return _itemClass;
        }

        public function set itemClass(value:Class):void
        {
            if (_itemClass == value)
            {
                return;
            }

            _itemClass = value;
            invalidate();
        }

        /**
         * Custom height of item.
         */
        public function get itemHeight():int
        {
            return _itemHeight;
        }

        public function set itemHeight(value:int):void
        {
            if (_itemHeight == value)
            {
                return;
            }

            _itemHeight = value;
            invalidate();
        }

        /**
         * Allow multiselection items.
         */
        public function get allowMultiSelection():Boolean
        {
            return _allowMultiSelection;
        }

        public function set allowMultiSelection(value:Boolean):void
        {
            if (_allowMultiSelection == value)
            {
                return;
            }

            _allowMultiSelection = value;
            updateMultiSelectionState();
        }

        /**
         * Custom keys fot multiselect items.
         */
        public function get multiSelectionKeyCodes():Vector.<uint>
        {
            return _multiSelectionKeyCodes;
        }

        public function set multiSelectionKeyCodes(value:Vector.<uint>):void
        {
            _multiSelectionKeyCodes = value;
        }

        public function get alternateRows():Boolean
        {
            return _alternateRows;
        }

        public function set alternateRows(value:Boolean):void
        {
            _alternateRows = value;
            invalidate();
        }

        public function get defaultColor():uint
        {
            return _defaultColor;
        }

        public function set defaultColor(value:uint):void
        {
            _defaultColor = value;
            invalidate();
        }

        public function get alternateColor():uint
        {
            return _alternateColor;
        }

        public function set alternateColor(value:uint):void
        {
            _alternateColor = value;
            invalidate();
        }

        public function get selectedColor():uint
        {
            return _selectedColor;
        }

        public function set selectedColor(value:uint):void
        {
            _selectedColor = value;
            invalidate();
        }

        public function get rolloverColor():uint
        {
            return _rolloverColor;
        }

        public function set rolloverColor(value:uint):void
        {
            _rolloverColor = value;
            invalidate();
        }

        public function get highlightOnHover():Boolean
        {
            return _highlightOnHover;
        }

        public function set highlightOnHover(value:Boolean):void
        {
            _highlightOnHover = value;
            invalidate();
        }

        public function get selectable():Boolean
        {
            return _selectable;
        }

        public function set selectable(value:Boolean):void
        {
            _selectable = value;
            invalidate();
        }
    }
}
