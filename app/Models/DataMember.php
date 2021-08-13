<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DataMember extends Model
{
    protected $table='data_members';

    public $incrementing = false;
    public $fillable = ['id','loan_id','polis_number','bank_id','branch_id','product_id','customer_name','is_uploaded_to_ajb_core','ibu_kandung','gender','jw_th','jw_bl','jw_hr'];

    function bank() {
        return $this->belongsTo('App\Models\MasterBank');
    }

    function branch() {
        return $this->belongsTo('App\Models\MasterBranch');
    }

    function product() {
        return $this->belongsTo('App\Models\MasterProduct');
    }

    function record_status() {
        return $this->belongsTo('App\Models\MasterRecordStatus');
    }

    function data_status() {
        return $this->belongsTo('App\Models\MasterDataStatus');
    }


    // public function masterbank()
    // {
    //     return $this->hasOne('App\Model\MasterBank','id','id_bank');
    // }
}
