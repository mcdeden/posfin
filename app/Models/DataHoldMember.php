<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DataHoldMember extends Model
{
    protected $table='data_hold_members';

    public $incrementing = false;
    public $fillable = ['loan_id','bank_id','branch_id','product_id','customer_name'];

    function bank() {
        return $this->belongsTo('App\Models\MasterBank');
    }

    function branch() {
        return $this->belongsTo('App\Models\MasterBranch');
    }

    function product() {
        return $this->belongsTo('App\Models\MasterProduct');
    }

    function data_status() {
        return $this->belongsTo('App\Models\MasterDataStatus','data_status_id','id');
    }

    function validation_status() {
        return $this->belongsTo('App\Models\MasterValidationStatus','validation_status_id','id');
    }


}
