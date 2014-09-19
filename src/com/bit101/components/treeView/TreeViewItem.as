package com.bit101.components.treeView
{
    import com.bit101.components.Component;
    import com.bit101.components.Label;
    import com.bit101.components.Style;

    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    /**
     * @history create 16.09.14 16:45
     * @author Sergey Smirnov
     */
    public class TreeViewItem extends Component
    {
        //------------------------------------------------
        //      Class constants
        //------------------------------------------------

        //------------------------------------------------
        //      Variables
        //------------------------------------------------

        protected var _treeView:TreeView;
        protected var _node:TreeViewNode;
        protected var _expandButton:DisplayObject;
        protected var _label:Label;

        protected var _defaultColor:uint;
        protected var _selectedColor:uint;
        protected var _rolloverColor:uint;

        protected var _isSelected:Boolean;
        protected var _isOvered:Boolean;
        private var _highlightOnHover:Boolean;

        private var _indentMultiplier:int;

        //---------------------------------------------------------------
        //
        //      CONSTRUCTOR
        //
        //---------------------------------------------------------------

        public function TreeViewItem(treeView:TreeView, parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
        {
            _treeView = treeView;

            _defaultColor = Style.LIST_DEFAULT;
            _selectedColor = Style.LIST_SELECTED;
            _rolloverColor = Style.LIST_ROLLOVER;

            _isSelected = false;
            _isOvered = false;
            _highlightOnHover = true;

            _indentMultiplier = 15;

            super(parent, xpos, ypos);
        }

        //---------------------------------------------------------------
        //
        //      PRIVATE & PROTECTED METHODS
        //
        //---------------------------------------------------------------

        protected function createExpandButton():DisplayObject
        {
            var result:Sprite = new Sprite();

            result.graphics.beginFill(0, 0);
            result.graphics.drawRect(-10, -10, 20, 20);
            result.graphics.endFill();
            result.graphics.beginFill(0, .35);
            result.graphics.moveTo(-5, -3);
            result.graphics.lineTo(5, -3);
            result.graphics.lineTo(0, 4);
            result.graphics.lineTo(-5, -3);
            result.graphics.endFill();

            result.useHandCursor = true;
            result.buttonMode = true;

            return result;
        }

        /**
         * @inheritDoc
         */
        override protected function init():void
        {
            super.init();
            this.setSize(100, 20);
            this.doubleClickEnabled = true;
            updateHighlightingOnHoverState();
        }

        /**
         * @inheritDoc
         */
        override protected function addChildren():void
        {
            super.addChildren();

            _expandButton = createExpandButton();
            addChild(_expandButton);

            _label = new Label(this, 5, 0);
            _label.draw();
        }

        protected function initListeners():void
        {
            _expandButton.addEventListener(MouseEvent.CLICK, onExpandButtonClick);
            this.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
        }

        protected function removeListeners():void
        {
            _expandButton.removeEventListener(MouseEvent.CLICK, onExpandButtonClick);
            this.removeEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
        }

        private function updateHighlightingOnHoverState():void
        {
            if (highlightOnHover)
            {
                this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
                this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            }
            else
            {
                _isOvered = false;
                this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
                this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            }
        }

        private function updateBackground():void
        {
            graphics.clear();

            if(isSelected)
            {
                graphics.beginFill(selectedColor);
            }
            else if(_isOvered)
            {
                graphics.beginFill(rolloverColor);
            }
            else
            {
                graphics.beginFill(defaultColor);
            }

            graphics.drawRect(0, 0, width, height);
            graphics.endFill();
        }

        private function updateExpandButton():void
        {
            _expandButton.visible = _node.children && _node.children.length > 0;

            _expandButton.x = ((_node.indent - 1) * _indentMultiplier) + 10;
            _expandButton.y = 10;
            _expandButton.rotation = _node.isExpanded ? 0 : -90;
        }

        private function updateLabel():void
        {
            _label.text = _node.name;
            _label.x = ((_node.indent - 1) * _indentMultiplier) + 20;
        }

        private function switchExpandButton():void
        {
            node.isExpanded ? node.collapse() : node.expand();
            _treeView.refresh();
        }

        //---------------------------------------------------------------
        //
        //      EVENT HANDLERS
        //
        //---------------------------------------------------------------

        public function onActivate():void
        {
            initListeners();
        }

        public function onDeactivate():void
        {
            removeListeners();
            _isOvered = false;
            _isSelected = false;
        }

        private function onExpandButtonClick(event:MouseEvent):void
        {
            switchExpandButton();
        }

        private function onMouseOver(event:MouseEvent):void
        {
            _isOvered = true;
            invalidate();
        }

        private function onMouseOut(event:MouseEvent):void
        {
            _isOvered = false;
            invalidate();
        }

        private function onDoubleClick(event:MouseEvent):void
        {
            if (_node.children.length <= 0)
            {
                return;
            }

            switchExpandButton();
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

            updateBackground();

            if (!_node)
            {
                return;
            }

            updateExpandButton();
            updateLabel();
        }

        public function select():void
        {
            if (_isSelected)
            {
                return;
            }

            _isSelected = true;
            invalidate();
        }

        public function unselect():void
        {
            if (!_isSelected)
            {
                return;
            }

            _isSelected = false;
            invalidate();
        }

        public function dispose():void
        {
            this.removeChild(_expandButton);
            this.removeChild(_label);

            _expandButton = null;
            _label = null;
            _node = null;
            _treeView = null;
        }

        //---------------------------------------------------------------
        //
        //      ACCESSORS
        //
        //---------------------------------------------------------------

        public function get node():TreeViewNode
        {
            return _node;
        }

        public function set node(value:TreeViewNode):void
        {
            _node = value;
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

        public function get indentMultiplier():int
        {
            return _indentMultiplier;
        }

        public function set indentMultiplier(value:int):void
        {
            _indentMultiplier = value;
            invalidate();
        }

        public function get isSelected():Boolean
        {
            return _isSelected;
        }

        public function get highlightOnHover():Boolean
        {
            return _highlightOnHover;
        }

        public function set highlightOnHover(value:Boolean):void
        {
            _highlightOnHover = value;
            updateHighlightingOnHoverState();
            invalidate();
        }
    }
}
