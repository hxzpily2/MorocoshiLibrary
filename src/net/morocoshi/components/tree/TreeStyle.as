package net.morocoshi.components.tree
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	
	/**
	 * ツリー表示用スタイル
	 * 
	 * @author	tencho
	 */
	public class TreeStyle
	{
		/**フォルダを開いた時の画像*/
		public var openIcon:BitmapData;
		/**フォルダを閉じた時の画像*/
		public var closeIcon:BitmapData;
		/**アイコンが無い時の画像*/
		public var noIcon:BitmapData;
		/**アイコン画像リスト*/
		public var icon:Object;
		/**テキストフォーマット*/
		public var textFormat:TextFormat;
		public var selectedBoxColor:uint;
		public var selectedLabelColor:uint;
		/**破線画像（縦）*/
		public var dotV:BitmapData;
		/**破線画像（横）*/
		public var dotH:BitmapData;
		/**フォルダ開閉ボタンのサイズ（奇数値推奨）*/
		public var buttonSize:Number;
		/**行間*/
		public var lineSpacing:Number;
		/**横線の長さ*/
		public var lineIndent:Number;
		/**ラベルの位置*/
		public var labelOffset:Point;
		public var treeOffset:Point;
		
		public function TreeStyle():void
		{
			icon = { };
			buttonSize = 11;
			lineSpacing = 20;
			lineIndent = 14;
			selectedBoxColor = 0x4CA4D8;
			selectedLabelColor = 0xFFFFFF;
			labelOffset = new Point(10, 0);
			treeOffset = new Point(8, 8);
			textFormat = new TextFormat("_sans", 14, 0x000000);
			dotV = new BitmapData(1, 2, true, 0);
			dotV.setPixel32(0, 0, 0xFF000000);
			dotH = new BitmapData(2, 1, true, 0);
			dotH.setPixel32(0, 0, 0xFF000000);
			noIcon = new BitmapData(3, 3, false, 0xFF000000);
			openIcon = new BitmapData(7, 7, false, 0xFF000000);
			openIcon.fillRect(new Rectangle(1, 1, 5, 5), 0xFFFFFFFF);
			closeIcon = openIcon.clone();
			closeIcon.fillRect(new Rectangle(2, 2, 3, 3), 0xFF000000);
		}
		
		/**
		 * Objectに設定可能な名前でアイコン画像を設定する。
		 * @param	name
		 * @param	bmd
		 */
		public function setIcon(name:String, bmd:BitmapData):void 
		{
			if (bmd)
			{
				icon[name] = bmd;
			}
			else
			{
				delete icon[name];
			}
		}
		
		/**
		 * 複製
		 */
		public function clone():TreeStyle
		{
			var newStyle:TreeStyle = new TreeStyle();
			for each(var v:XML in describeType(this).variable)
			{
				var type:String = v.@type;
				var name:String = v.@name;
				if (type == "Number" || type == "uint")
				{
					newStyle[name] = this[name];
				}
				if (type == "flash.geom::Point" || type == "flash.display::BitmapData")
				{
					newStyle[name] = this[name].clone();
				}
			}
			
			//icon
			for (var k:String in icon)
			{
				newStyle.icon[k] = icon[k] ? icon[k].clone() : null;
			}
			
			//TextFormat
			var ba:ByteArray = new ByteArray();
			ba.writeObject(textFormat);
			ba.position = 0;
			var obj:Object = ba.readObject();
			for (var g:String in obj)
			{
				newStyle.textFormat[g] = obj[g];
			}
			return newStyle;
		}
		
	}

}