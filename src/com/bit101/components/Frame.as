package com.bit101.components
{
    import flash.display.CapsStyle;
    import flash.display.DisplayObjectContainer;
    import flash.display.JointStyle;
    import flash.display.LineScaleMode;

    /**
     * @history Created on 9/5/14, 0:19.
     * @author Sergey Smirnov
     */
    public class Frame extends Component
    {
        //----------------------------------------------------------------------------------------------
        //
        //  Class constants
        //
        //----------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------
        //
        //  Class variables
        //
        //----------------------------------------------------------------------------------------------

        private var _thickness:Number;
        private var _bodyColor:uint;
        private var _borderColor:uint;
        private var _fillBody:Boolean;

        //----------------------------------------------------------------------------------------------
        //
        //  Class flags
        //
        //----------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------
        //
        //  Constructor
        //
        //----------------------------------------------------------------------------------------------

        public function Frame(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
        {
            super(parent, xpos, ypos);

            _thickness = 1.0;
            _borderColor = Style.FRAME_BORDER;
            _bodyColor = Style.FRAME_BODY;
            _fillBody = false;
        }

        //----------------------------------------------------------------------------------------------
        //
        //  Event handlers
        //
        //----------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------
        //
        //  Private Methods
        //
        //----------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------
        //
        //  Protected Methods
        //
        //----------------------------------------------------------------------------------------------

        override protected function init():void
        {
            super.init();
            setSize(100, 100);
        }

        protected function drawRBody():void
        {
            graphics.drawRect(0, 0, width, height);
        }

        //----------------------------------------------------------------------------------------------
        //
        //  Public Methods
        //
        //----------------------------------------------------------------------------------------------

        override public function draw():void
        {
            super.draw();

            graphics.clear();

            graphics.lineStyle(_thickness, _borderColor, 1.0, true, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);

            if (_fillBody)
            {
                graphics.beginFill(_bodyColor);
            }

            drawRBody();

            if (_fillBody)
            {
                graphics.endFill();
            }
        }

        //----------------------------------------------------------------------------------------------
        //
        //  Accessors
        //
        //----------------------------------------------------------------------------------------------

        public function get thickness():Number
        {
            return _thickness;
        }

        public function set thickness(value:Number):void
        {
            _thickness = value;
            invalidate();
        }

        public function get borderColor():uint
        {
            return _borderColor;
        }

        public function set borderColor(value:uint):void
        {
            _borderColor = value;
            invalidate();
        }

        public function get bodyColor():uint
        {
            return _bodyColor;
        }

        public function set bodyColor(value:uint):void
        {
            _bodyColor = value;
            invalidate();
        }

        public function get fillBody():Boolean
        {
            return _fillBody;
        }

        public function set fillBody(value:Boolean):void
        {
            _fillBody = value;
            invalidate();
        }
    }
}
