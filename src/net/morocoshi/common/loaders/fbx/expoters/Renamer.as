package net.morocoshi.common.loaders.fbx.expoters 
{
	/**
	 * 重複した名前をリネームする
	 * 
	 * @author tencho
	 */
	public class Renamer 
	{
		private var exsist:Object = { };
		private var index:Object = { };
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function Renamer() 
		{
		}
		
		/**
		 * リネーム情報をリセット
		 */
		public function clear():void
		{
			exsist = { };
			index = { };
		}
		
		/**
		 * 事前に名前を登録しておき、ここで登録した名前と被らないようにする。
		 * @param	name
		 */
		public function addName(name:String):void
		{
			exsist[name] = true;
			
			var match:Array = name.match(/^(.*)_(\d+)$/sm);
			var id:String = match? match[1] : name;
			var num:int = match? parseInt(match[2]) : 0;
			
			if (index[id] == null) index[id] = -1;
			if (index[id] < num) index[id] = num;
		}
		
		/**
		 * 指定の名前を他と被らない名前にリネームする。
		 * @param	name
		 * @return
		 */
		public function rename(name:String):String
		{
			var match:Array = name.match(/^(.*)_(\d+)$/sm);
			var id:String = match? match[1] : name;
			var num:int = match? parseInt(match[2]) : 0;
			
			if (index[id] == null) return name;
			return id + "_" + String(index[id] + 1);
		}
		
	}

}