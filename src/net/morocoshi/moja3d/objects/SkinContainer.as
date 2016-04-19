package net.morocoshi.moja3d.objects 
{
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;
	import net.morocoshi.common.data.DataUtil;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	
	use namespace moja3d;
	
	/**
	 * 複数のSkinオブジェクトとBoneを格納したスキンメッシュオブジェクト
	 * 
	 * @author tencho
	 */
	public class SkinContainer extends Object3D 
	{
		/**このスキン内にあるボーンオブジェクトのリスト*/
		public var bones:Vector.<Bone>;
		/**このスキン内にあるSkinオブジェクトのリスト*/
		public var skins:Vector.<Skin>;
		
		private var invertSkin:Matrix3D;
		
		private var boneContainers:Vector.<Object3D>;
		private var skinCount:int;
		private var showCount:int;
		private var skinVisible:Boolean;
		
		public function SkinContainer() 
		{
			super();
			
			skinVisible = true;
			boneContainers = new Vector.<Object3D>;
			invertSkin = new Matrix3D();
			bones = new Vector.<Bone>;
			skins = new Vector.<Skin>;
		}
		
		/**
		 * ポリゴンベースのアウトラインを設定する
		 * @param	enabled		表示するか
		 * @param	thickness	厚さ
		 * @param	color		色
		 * @param	alpha		不透明度
		 */
		public function setOutline(enabled:Boolean, thickness:Number = 1, color:uint = 0x000000, alpha:Number = 1):void
		{
			for each(var skin:Skin in skins)
			{
				skin.setOutline(enabled, thickness, color, alpha);
			}
		}
		/**
		 * ポリゴンベースのアウトラインを表示するか
		 */
		public function set outlineEnabled(value:Boolean):void
		{
			for each(var skin:Skin in skins)
			{
				skin.outlineEnabled = value;
			}
		}
		public function get outlineEnabled():Boolean
		{
			return (skins.length == 0)? 1 : skins[0].outlineEnabled;
		}
		
		/**
		 * ポリゴンベースのアウトラインの厚さ
		 */
		public function set outlineThickness(value:Number):void
		{
			for each(var skin:Skin in skins)
			{
				skin.outlineThickness = value;
			}
		}
		public function get outlineThickness():Number
		{
			return (skins.length == 0)? 1 : skins[0].outlineThickness;
		}
		
		/**
		 * ポリゴンベースのアウトラインの色
		 */
		public function set outlineColor(value:uint):void
		{
			for each(var skin:Skin in skins)
			{
				skin.outlineColor = value;
			}
		}
		public function get outlineColor():uint
		{
			return (skins.length == 0)? 0x000000 : skins[0].outlineColor;
		}
		
		/**
		 * ポリゴンベースのアウトラインの不透明度
		 */
		public function set outlineAlpha(value:Number):void
		{
			for each(var skin:Skin in skins)
			{
				skin.outlineAlpha = value;
			}
		}
		public function get outlineAlpha():Number
		{
			return (skins.length == 0)? 1 : skins[0].outlineAlpha;
		}
		
		/**
		 * スキンメッシュの現在の姿勢で境界ボックスを更新する。ボーンの初期姿勢からのずれで計算するため実際のメッシュより大きく設定される傾向にあります。
		 */
		public function updateSkinBounds(bones:Vector.<Bone>):void
		{
			var skin:Skin;
			for each (skin in skins) 
			{
				skin.updateSkinBounds(bones);
			}
			skin = null;
		}
		
		override protected function calculate(collector:RenderCollector):void 
		{
			//スキン姿勢の逆行列の計算
			invertSkin.copyFrom(_worldMatrix);
			invertSkin.invert();
			
			var skin:Skin;
			for each (skin in skins) 
			{
				skin.updateBoneConstants(invertSkin);
			}
			skin = null;
		}
		
		/**
		 * スキン内にあるボーンオブジェクトを収集して必要なシェーダーを生成する
		 */
		public function collectBones():void
		{
			bones.length = 0;
			skins.length = 0;
			
			var current:Object3D;
			var bone:Bone;
			
			//Boneが入っている可能性のあるコンテナを調べる
			var containerDic:Dictionary = new Dictionary();
			boneContainers.length = 0;
			for (current = _children; current; current = current._next)
			{
				if (current is Skin) continue;
				containerDic[current] = true;
			}
			
			var task:Vector.<Object3D> = new <Object3D>[this];
			while (task.length)
			{
				current = task.pop()._children;
				while (current)
				{
					if (current is Skin)
					{
						skins.push(current as Skin);
					}
					bone = current as Bone;
					if (bone && bone.hasWeight)
					{
						bones.push(bone);
						for (var p:Object3D = bone._parent; p; p = p._parent)
						{
							if (containerDic[p]) VectorUtil.attachItemDiff(boneContainers, p);
						}
					}
					task.push(current);
					current = current._next;
				}
			}
			
			task = null;
			current = null;
			bone = null;
			
			var skin:Skin;
			for each (skin in skins) 
			{
				skin.createSkinShader(bones);
			}
			skin = null;
		}
		
		override public function finaly():void 
		{
			super.finaly();
			
			DataUtil.deleteVector(bones);
			DataUtil.deleteVector(skins);
			bones = null;
			skins = null;
			invertSkin = null;
		}
		
		override public function referenceProperties(target:Object3D):void
		{
			super.referenceProperties(target);
			
			var skin:SkinContainer = target as SkinContainer;
			skin.skinVisible = skinVisible;
			skin = null;
		}
		
		override public function cloneProperties(target:Object3D):void 
		{
			super.cloneProperties(target);
			
			var skin:SkinContainer = target as SkinContainer;
			skin.skinVisible = skinVisible;
			skin = null;
		}
		
		override public function clone():Object3D 
		{
			var result:SkinContainer = new SkinContainer();
			
			cloneProperties(result);
			
			//子を再帰的にコピーする
			var current:Object3D;
			for (current = _children; current; current = current._next)
			{
				result.addChild(current.clone());
			}
			
			result.collectBones();
			
			return result;
		}
		
		override public function reference():Object3D 
		{
			var result:SkinContainer = new SkinContainer();
			
			referenceProperties(result);
			
			//子を再帰的にコピーする
			var current:Object3D;
			for (current = _children; current; current = current._next)
			{
				result.addChild(current.reference());
			}
			
			result.collectBones();
			
			return result;
		}
		
		override moja3d function collectRenderElements(collector:RenderCollector, forceCalcMatrix:Boolean, forceCalcColor:Boolean, forceCalcBounds:Boolean, worldFlip:int, mask:int):Boolean 
		{
			skinCount = showCount = skins.length;
			var result:Boolean = super.collectRenderElements(collector, forceCalcMatrix, forceCalcColor, forceCalcBounds, worldFlip, mask);
			
			return result;
		}
		
		/**
		 * 子のSkinの描画判定が確定した時に呼ばれる
		 */
		moja3d function applySkinVisible(show:Boolean):void 
		{
			skinCount--;
			showCount -= int(!show);
			//全てのスキンの描画判定が確定した場合
			if (skinCount == 0)
			{
				//どれか1つでもスキンが表示されているか？
				var v:Boolean = showCount != 0;
				if (skinVisible != v)
				{
					skinVisible = v;
					//スキンが描画されないなら、ボーンコンテナを非表示にして負荷を下げる
					for each(var container:Object3D in boneContainers)
					{
						container.visible = skinVisible;
					}
				}
			}
		}
		
	}

}